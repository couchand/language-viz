# language visualizations

w = 300
h = 200

margin = 100

selected_lang = "Scala"

x_column = "cpu(s)"
y_column = "mem(KB)"

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

d3.csv "languages.csv", (data) ->
  for d in data
    d[x_column] = parseFloat d[x_column]
    d[y_column] = parseFloat d[y_column]

  x.domain d3.extent data, getX
  y.domain d3.extent data, getY
  x.nice()
  y.nice()

  averages = average.map data

  svg = d3.select("#viz").append("svg")
    .attr("width", w + margin + margin)
    .attr("height", h + margin + margin)
    .append("g")
    .attr("transform", "translate(#{margin},#{margin})")

  benchmark = svg.selectAll(".benchmark")
    .data(data)
    .enter().append("g")
    .classed("benchmark", -> yes)
    .attr "transform", (d) ->
      "translate(#{getX0 d},#{getY0 d})"

  dots = benchmark.append("circle")
    .attr("r", 2)
    .attr("fill", "#d88")
    .attr("opacity", .6)

  lines = benchmark.append("path")
    .attr("stroke", (d) -> if d.lang is selected_lang then "#555" else "none")
    .attr("opacity", .6)
    .attr "d", (d) ->
      avg = averages[d.lang]
      cx = getX0(avg) - getX0(d)
      cy = getY0(avg) - getY0(d)
      "M 0 0 L #{cx} #{cy}"
