# language visualizations

w = 150
h = 150

margin = 10

row_count = 6

selected_lang = "Scala"

x_column = "cpu(s)"
y_column = "size(B)"

getX = (d) -> d[x_column]
getY = (d) -> d[y_column]

x = d3.scale.sqrt()
    .rangeRound [0, w]

y = d3.scale.sqrt()
    .rangeRound [h, 0]

getX0 = (d) -> x getX d
getY0 = (d) -> y getY d

average = d3.nest()
  .key((d) -> d.lang)
  .rollup (v) ->
    m = {}
    m[x_column] = d3.mean v, getX
    m[y_column] = d3.mean v, getY
    m

best = d3.nest()
  .key((d) -> d.name)
  .rollup (v) ->
    m = {}
    m[x_column] = d3.min v, getX
    m[y_column] = d3.min v, getY
    m

byLanguage = d3.nest()
  .key((d) -> d.lang)

languagesByX = d3.nest()
  .key(getX)
  .sortKeys((a,b) -> d3.ascending parseFloat(a), parseFloat(b))

languagesByY = d3.nest()
  .key(getY)
  .sortKeys((a,b) -> d3.ascending parseFloat(a), parseFloat(b))

languagesByXThenY = (a) ->
  byX = languagesByX.entries a
  cols = (byX.slice i, Math.min(byX.length-1,i+row_count) for i in [0..byX.length] by row_count)
  ((l.values[0] for l in languagesByY.entries(cell.values[0] for cell in col)) for col in cols)

d3.csv "languages.csv", (data) ->
  for d in data
    d[x_column] = parseFloat d[x_column]
    d[y_column] = parseFloat d[y_column]

  mins = best.map data

  for d in data
    d[x_column] = getX(d) / getX(mins[d.name])
    d[y_column] = getY(d) / getY(mins[d.name])

  x.domain [0, 5000]
  y.domain [1, 6]

  #x.domain d3.extent data, getX
  #y.domain d3.extent data, getY
  #x.nice()
  #y.nice()

  averages = average.map data

  flat_averages = []
  for lang, avg of averages
    m = {}
    m.lang = lang
    m[x_column] = getX(avg)
    m[y_column] = getY(avg)
    flat_averages.push m

  layout = languagesByXThenY flat_averages

  lang_benches = byLanguage.map data

  col = d3.select("#viz").selectAll(".col")
    .data(layout)
    .enter().append("div")
    .classed("col", -> yes)

  svg = col.selectAll("svg")
    .data((d) -> d)
    .enter().append("svg")
    .attr("width", w + margin + margin)
    .attr("height", h + margin + margin)
    .append("g")
    .attr("transform", "translate(#{margin},#{margin})")

  svg.append("title")
    .text (d) -> d.lang

  clip = svg.append("defs").append("clipPath")
    .attr("id", "clip")
    .append("rect")
    .attr("width", w)
    .attr("height", h)

  focus = svg.append("g")
    .attr("clip-path", "url(#clip)")

  benchmark = focus.selectAll(".benchmark")
    .data(data)
    .enter().append("g")
    .classed("benchmark", -> yes)
    .attr "transform", (d) ->
      "translate(#{getX0 d},#{getY0 d})"

  dots = benchmark.append("circle")
    .attr("r", 2)
    .attr("fill", "#d88")
    .attr("opacity", .6)

  lines

  star = focus.append("g")
    .classed("star", -> yes)
    .attr "transform", (d) ->
      avg = averages[d.lang]
      "translate(#{getX0 avg},#{getY0 avg})"

  lines = star.selectAll("path")
    .data((d) -> lang_benches[d.lang])
    .enter().append("path")
    .attr("opacity", .6)
    .attr("stroke", "#555")
    .attr "d", (d) ->
      avg = averages[d.lang]
      cx = getX0(d) - getX0(avg)
      cy = getY0(d) - getY0(avg)
      "M 0 0 L #{cx} #{cy}"

  focus.append("rect")
    .attr("width", w)
    .attr("height", h)
    .attr("stroke", "#444")
    .attr("fill", "none")
