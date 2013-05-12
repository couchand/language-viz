# language visualizations abstract base class

class LanguageGraph
  constructor: (@width, @height) ->
    @container = "#viz"

    @x_column = "cpu(s)"
    @y_column = "size(B)"

    @scaleX.rangeRound [0, @width]
    @scaleY.rangeRound [@height, 0]

    @average = @rollup 'lang', 'mean'
    @best = @rollup 'name', 'min'

  lang: (d) -> d.lang

  scaleX: d3.scale.sqrt()
  scaleY: d3.scale.sqrt()

  getX: (d) -> d[@x_column]
  getY: (d) -> d[@y_column]
  x: ->
    t = @
    (d) -> t.getX d
  y: ->
    t = @
    (d) -> t.getY d

  setX: (d, x) -> d[@x_column] = x
  setY: (d, y) -> d[@y_column] = y

  getX0: (d) -> @scaleX @getX d
  getY0: (d) -> @scaleY @getY d

  rect: (c) ->
    c.append("rect")
      .attr("width", @width)
      .attr("height", @height)

  rollup: (k, f) ->
    d3.nest()
      .key((d) -> d[k])
      .rollup @rollupFunction f

  rollupFunction: (f) ->
    t = @
    (v) ->
      m = {}
      t.setX m, d3[f] v, myStars.x()
      t.setY m, d3[f] v, myStars.y()
      m

  clean: (data) ->
    for d in data
      @setX d, parseFloat @getX d
      @setY d, parseFloat @getY d

  relativize: (data) ->
    mins = @best.map data

    for d in data
      @setX d, @getX(d) / @getX(mins[d.name])
      @setY d, @getY(d) / @getY(mins[d.name])

    @scaleX.domain [0, 5000]
    @scaleY.domain [1, 6]

  spoke: ->
    t = @
    (d) ->
      avg = t.averages[d.lang]
      cx = t.getX0(d) - t.getX0(avg)
      cy = t.getY0(d) - t.getY0(avg)
      "M 0 0 L #{cx} #{cy}"

  centerStar: ->
    t = @
    (d) ->
      avg = t.averages[d.lang]
      "translate(#{t.getX0 avg},#{t.getY0 avg})"

  drawBorder: (focus) ->
    @rect(focus).classed('border', -> yes)

  benchmarksForLanguage: ->
    t = @
    (d) ->
      t.lang_benches[d.lang]

  drawLines: (star) ->
    t = @
    star.selectAll("path")
      .data(@benchmarksForLanguage())
      .enter().append("path")
      .attr("d", @spoke())

  drawStar: (focus) ->
    star = focus.append("g")
      .classed("star", -> yes)
      .attr("transform", @centerStar())

    @drawLines star

  sortByLanguage: (data) ->
    @lang_benches = d3.nest().key((d) -> d.lang).map data

  doAverage: (data) ->
    @averages = @average.map data

  initialize: (data) ->
    @clean data
    @relativize data
    @doAverage data
