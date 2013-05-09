# language visualizations

w = 300
h = 200

margin = 100

x_column = "cpu(s)"
y_column = "mem(KB)"

x = d3.scale.sqrt()
    .rangeRound [0, w]

y = d3.scale.sqrt()
    .rangeRound [h, 0]

color = d3.scale.category20()

d3.csv "languages.csv", (data) ->
  for d in data
    d[x_column] = parseFloat d[x_column]
    d[y_column] = parseFloat d[y_column]

  x.domain d3.extent data, (d) -> d[x_column]
  y.domain d3.extent data, (d) -> d[y_column]
  x.nice()
  y.nice()

  svg = d3.select("#viz").append("svg")
    .attr("width", w + margin + margin)
    .attr("height", h + margin + margin)
    .append("g")
    .attr("transform", "translate(#{margin},#{margin})")

  dots = svg.selectAll(".dot")
    .data(data)
    .enter().append("circle")
    .classed("dot", -> yes)
    .attr("r", 2)
    .attr("fill", (d) -> color d['lang'])
    .attr("opacity", .4)
    .attr "transform", (d) ->
      "translate(#{x d[x_column]},#{y d[y_column]})"
