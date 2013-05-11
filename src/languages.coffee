# language visualizations

class CategoryStars
  constructor: (@width, @height) ->
    @width ?= 40
    @height ?= 40
    @row_count = 5

    @x_column = "cpu(s)"
    @y_column = "size(B)"
    @scaleX.rangeRound [0, @width]
    @scaleY.rangeRound [@height, 0]

  scaleX: d3.scale.sqrt()
  scaleY: d3.scale.sqrt()
  lang: (d) -> d.lang

  getX: (d) -> d[@x_column]
  getY: (d) -> d[@y_column]

myStars = new CategoryStars

setX = (d, x) -> d[myStars.x_column] = x
setY = (d, y) -> d[myStars.y_column] = y

getX0 = (d) -> myStars.scaleX myStars.getX d
getY0 = (d) -> myStars.scaleY myStars.getY d

background = d3.scale.ordinal()
    .domain(['imperative', 'oo', 'functional', 'scripting'])
    .range(['#6da', '#97e', '#fe7', '#fa7'])

type = (d) ->
  background types[d.lang]

rollup = (k, f) ->
  d3.nest()
    .key((d) -> d[k])
    .rollup (v) ->
      m = {}
      setX m, d3[f] v, (d) -> myStars.getX d
      setY m, d3[f] v, (d) -> myStars.getY d
      m

average = rollup 'lang', 'mean'
best = rollup 'name', 'min'

byLanguage = d3.nest()
  .key(myStars.lang)

languagesByX = d3.nest()
  .key((d) -> myStars.getX d)
  .sortKeys((a,b) -> d3.ascending parseFloat(a), parseFloat(b))

languagesByY = d3.nest()
  .key((d) -> myStars.getY d)
  .sortKeys((a,b) -> d3.descending parseFloat(a), parseFloat(b))

matrixValues = (cols) ->
  ((cell.values[0] for cell in col) for col in cols)

languagesByXThenY = (a) ->
  chunk = myStars.row_count
  byX = languagesByX.entries a
  end = (i) -> Math.min byX.length - 1, i + chunk
  cols = (byX.slice i, end i for i in [0..byX.length] by chunk)
  cols = matrixValues cols
  matrixValues (languagesByY.entries col for col in cols)

flatten = (lng, avg) ->
  m = {}
  m.lang = lng
  setX m, myStars.getX avg
  setY m, myStars.getY avg
  m

rect = (c) ->
  c.append("rect")
    .attr("width", myStars.width)
    .attr("height", myStars.height)

d3.csv "data.csv", (data) ->
  for d in data
    setX d, parseFloat myStars.getX d
    setY d, parseFloat myStars.getY d

  mins = best.map data

  for d in data
    setX d, myStars.getX(d) / myStars.getX(mins[d.name])
    setY d, myStars.getY(d) / myStars.getY(mins[d.name])

  myStars.scaleX.domain [0, 5000]
  myStars.scaleY.domain [1, 6]

  #x.domain d3.extent data, getX
  #y.domain d3.extent data, getY
  #x.nice()
  #y.nice()

  averages = average.map data

  flat_averages = (flatten lng, avg for lng, avg of averages)
  layout = languagesByXThenY flat_averages

  lang_benches = byLanguage.map data

  spoke = (d) ->
    avg = averages[d.lang]
    cx = getX0(d) - getX0(avg)
    cy = getY0(d) - getY0(avg)
    "M 0 0 L #{cx} #{cy}"

  col = d3.select("#viz").selectAll(".col")
    .data(layout)
    .enter().append("div")
    .classed("col", -> yes)

  focus = smallMultiples col,
    width: myStars.width
    height: myStars.height
    margin:
      left: 40
      right: 40
      top: 10
      bottom: 10
    title:
      size: 10
      padding: 5
      data: myStars.lang

  rect(focus).attr "fill", type

  star = focus.append("g")
    .classed("star", -> yes)
    .attr "transform", (d) ->
      avg = averages[d.lang]
      "translate(#{getX0 avg},#{getY0 avg})"

  lines = star.selectAll("path")
    .data((d) -> lang_benches[d.lang])
    .enter().append("path")
    .attr("d", spoke)

  rect(focus).classed 'border', -> yes
