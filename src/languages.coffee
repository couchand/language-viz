# language visualizations

class CategoryStars
  constructor: (@width, @height) ->
    @width ?= 40
    @height ?= 40
    @row_count = 5

    @container = "#viz"

    @x_column = "cpu(s)"
    @y_column = "size(B)"
    @scaleX.rangeRound [0, @width]
    @scaleY.rangeRound [@height, 0]

    @average = @rollup 'lang', 'mean'
    @best = @rollup 'name', 'min'

    @languagesByX.key @.x()
    @languagesByY.key @.y()

  scaleX: d3.scale.sqrt()
  scaleY: d3.scale.sqrt()
  lang: (d) -> d.lang

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

  typeColor: d3.scale.ordinal()
      .domain(['imperative', 'oo', 'functional', 'scripting'])
      .range(['#6da', '#97e', '#fe7', '#fa7'])

  background: ->
    t = @
    (d) -> t.typeColor types[d.lang]

  rect: (c) ->
    c.append("rect")
      .attr("width", @width)
      .attr("height", @height)

  flatten: (lng, avg) ->
    m = {}
    m.lang = lng
    @setX m, @getX avg
    @setY m, @getY avg
    m

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

  doAverage: (data) ->
    @averages = @average.map data
    @flat_averages = (@flatten lng, avg for lng, avg of @averages)

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

  drawBackground: (focus) ->
    @rect(focus).attr("fill", @background())
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

  languagesByX: d3.nest()
      .sortKeys((a,b) -> d3.ascending parseFloat(a), parseFloat(b))

  languagesByY: d3.nest()
      .sortKeys((a,b) -> d3.descending parseFloat(a), parseFloat(b))

  matrixValues: (cols) ->
    ((cell.values[0] for cell in col) for col in cols)

  languagesByXThenY: ->
    chunk = @row_count
    byX = @languagesByX.entries @flat_averages
    end = (i) -> Math.min byX.length - 1, i + chunk
    cols = (byX.slice i, end i for i in [0..byX.length] by chunk)
    cols = @matrixValues cols
    @matrixValues (@languagesByY.entries col for col in cols)

  layoutColumns: ->
    d3.select(@container).selectAll(".col")
      .data(@languagesByXThenY())
      .enter().append("div")
      .classed("col", -> yes)

  layoutCells: (col) ->
    smallMultiples col,
      width: @width
      height: @height
      margin:
        left: 40
        right: 40
        top: 10
        bottom: 10
      title:
        size: 10
        padding: 5
        data: @lang

  createLayout: ->
    @layoutCells @layoutColumns()

  draw: (data) ->
    @clean data
    @relativize data
    @doAverage data
    @sortByLanguage data

    focus = @createLayout()

    @drawBackground focus
    @drawStar focus
    @drawBorder focus

myStars = new CategoryStars

d3.csv "data.csv", (data) ->
  myStars.draw data
