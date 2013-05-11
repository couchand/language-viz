# small multiples
# assumes the container has a datum array of the categories

smallMultiples = (container, options) ->
  w = options.width or 0
  w += options.margin.left or 0
  w += options.margin.right or 0
  h = options.height or 0
  h += options.margin.top or 0
  h += options.margin.bottom or 0
  h += options.title.size or 0
  h += options.title.padding or 0
  ml = options.margin.left or 0
  mt = options.margin.top or 0
  mt += options.title.height or 0
  mt += options.title.padding or 0
  fw = options.width or 0
  fh = options.height or 0
  ts = options.title.size or 0
  td = options.title.data or -> ''

  svg = container.selectAll("svg")
    .data((d) -> d)
    .enter().append("svg")
    .attr("width", w)
    .attr("height", h)
    .append("g")
    .attr("transform", "translate(#{ml},#{mt})")

  svg.append("title")
    .text td

  svg.append("text")
    .attr("x", fw/2)
    .attr("y", -4)
    .style("font-size", ts)
    .attr("text-anchor", "middle")
    .text td

  clip = svg.append("defs").append("clipPath")
    .attr("id", (d,i) -> "clip#{i}")
    .append("rect")
    .attr("width", fw)
    .attr("height", fh)

  focus = svg.append("g")
    .attr("clip-path", (d,i) -> "url(#clip#{i})")
