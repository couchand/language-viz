# language visualizations

width = 40
height = 40
row_count = 5

x_column = "cpu(s)"
y_column = "size(B)"

lang = (d) -> d.lang

getX = (d) -> d[x_column]
getY = (d) -> d[y_column]

setX = (d, x) -> d[x_column] = x
setY = (d, y) -> d[y_column] = y

x = d3.scale.sqrt()
    .rangeRound [0, width]

y = d3.scale.sqrt()
    .rangeRound [height, 0]

getX0 = (d) -> x getX d
getY0 = (d) -> y getY d

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
      setX m, d3[f] v, getX
      setY m, d3[f] v, getY
      m

average = rollup 'lang', 'mean'
best = rollup 'name', 'min'

byLanguage = d3.nest()
  .key(lang)

languagesByX = d3.nest()
  .key(getX)
  .sortKeys((a,b) -> d3.ascending parseFloat(a), parseFloat(b))

languagesByY = d3.nest()
  .key(getY)
  .sortKeys((a,b) -> d3.descending parseFloat(a), parseFloat(b))

matrixValues = (cols) ->
  ((cell.values[0] for cell in col) for col in cols)

languagesByXThenY = (a) ->
  byX = languagesByX.entries a
  end = (i) -> Math.min byX.length - 1, i + row_count
  cols = (byX.slice i, end i for i in [0..byX.length] by row_count)
  cols = matrixValues cols
  matrixValues (languagesByY.entries col for col in cols)

flatten = (lng, avg) ->
  m = {}
  m.lang = lng
  setX m, getX avg
  setY m, getY avg
  m

rect = (c) ->
  c.append("rect")
    .attr("width", width)
    .attr("height", height)

d3.csv "data.csv", (data) ->
  for d in data
    setX d, parseFloat getX d
    setY d, parseFloat getY d

  mins = best.map data

  for d in data
    setX d, getX(d) / getX(mins[d.name])
    setY d, getY(d) / getY(mins[d.name])

  x.domain [0, 5000]
  y.domain [1, 6]

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
    width: width
    height: height
    margin:
      left: 40
      right: 40
      top: 10
      bottom: 10
    title:
      size: 10
      padding: 5
      data: lang

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
