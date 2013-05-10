# language visualizations

w = 40
h = 40

margin_w = 40
margin_h = 10

title_h = 15
title_f = 10

row_count = 5

x_column = "cpu(s)"
y_column = "size(B)"

getX = (d) -> d[x_column]
getY = (d) -> d[y_column]

setX = (d, x) -> d[x_column] = x
setY = (d, y) -> d[y_column] = y

x = d3.scale.sqrt()
    .rangeRound [0, w]

y = d3.scale.sqrt()
    .rangeRound [h, 0]

getX0 = (d) -> x getX d
getY0 = (d) -> y getY d

background = d3.scale.ordinal()
    .domain(['imperative', 'oo', 'functional', 'scripting'])
    .range(['#6da', '#97e', '#fe7', '#fa7'])

types = {
  'C gcc': 'imperative'
  'Pascal Free Pascal': 'imperative'
  'Go': 'imperative'
  'Fortran Intel': 'imperative'
  'C++ g++': 'oo'
  'Scala': 'oo'
  'Smalltalk VisualWorks': 'oo'
  'Ada 2005 GNAT': 'oo'
  'Java 7': 'oo'
  'C# Mono': 'oo'
  'Dart': 'oo'
  'ATS': 'functional'
  'OCaml': 'functional'
  'F# Mono': 'functional'
  'Erlang HiPE': 'functional'
  'Lisp SBCL': 'functional'
  'Haskell GHC': 'functional'
  'Clojure': 'functional'
  'Racket': 'functional'
  'Lua': 'scripting'
  'PHP': 'scripting'
  'Python 3': 'scripting'
  'Ruby 2.0': 'scripting'
  'JavaScript V8': 'scripting'
  'Ruby JRuby': 'scripting'
  'Perl': 'scripting'
}

type = (d) ->
  types[d.lang]

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
  .key((d) -> d.lang)

languagesByX = d3.nest()
  .key(getX)
  .sortKeys((a,b) -> d3.ascending parseFloat(a), parseFloat(b))

languagesByY = d3.nest()
  .key(getY)
  .sortKeys((a,b) -> d3.descending parseFloat(a), parseFloat(b))

languagesByXThenY = (a) ->
  byX = languagesByX.entries a
  end = (i) -> Math.min byX.length - 1, i + row_count
  cols = (byX.slice i, end i for i in [0..byX.length] by row_count)
  cols = ((cell.values[0] for cell in col) for col in cols)
  cols = (languagesByY.entries col for col in cols)
  ((cell.values[0] for cell in col) for col in cols)

d3.csv "languages.csv", (data) ->
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

  flat_averages = []
  for lang, avg of averages
    m = {}
    m.lang = lang
    setX m, getX(avg)
    setY m, getY(avg)
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
    .attr("width", w + margin_w + margin_w)
    .attr("height", h + margin_h + margin_h + title_h)
    .append("g")
    .attr("transform", "translate(#{margin_w},#{margin_h + title_h})")

  svg.append("title")
    .text (d) -> d.lang

  svg.append("text")
    .attr("x", w/2)
    .attr("y", -4)
    .style("font-size", title_f)
    .attr("text-anchor", "middle")
    .text (d) -> d.lang

  clip = svg.append("defs").append("clipPath")
    .attr("id", "clip")
    .append("rect")
    .attr("width", w)
    .attr("height", h)

  focus = svg.append("g")
    .attr("clip-path", "url(#clip)")

  focus.append("rect")
    .attr("width", w)
    .attr("height", h)
    .attr("stroke", "none")
    .attr("fill", (d) -> background type d)

  star = focus.append("g")
    .classed("star", -> yes)
    .attr "transform", (d) ->
      avg = averages[d.lang]
      "translate(#{getX0 avg},#{getY0 avg})"

  lines = star.selectAll("path")
    .data((d) -> lang_benches[d.lang])
    .enter().append("path")
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
