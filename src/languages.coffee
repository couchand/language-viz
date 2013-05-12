# language visualizations

class LanguageGraphMatrix extends LanguageGraph
  constructor: (w, h) ->
    w ?= 40
    h ?= 40
    super w, h

    @row_count = 5

    @languagesByX.key @.x()
    @languagesByY.key @.y()

  flatten: (lng, avg) ->
    m = {}
    m.lang = lng
    @setX m, @getX avg
    @setY m, @getY avg
    m

  flattenAverages: ->
    @flat_averages = (@flatten lng, avg for lng, avg of @averages)

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
    @initialize data
    @flattenAverages()

    focus = @createLayout()
    @render focus

  render: (focus) ->
    @drawStar focus
    @drawBorder focus

class CategoryStars extends LanguageGraphMatrix
  typeColor: d3.scale.ordinal()
      .domain(['imperative', 'oo', 'functional', 'scripting'])
      .range(['#6da', '#97e', '#fe7', '#fa7'])

  background: ->
    t = @
    (d) -> t.typeColor types[d.lang]

  drawBackground: (focus) ->
    @rect(focus).attr("fill", @background())

  render: (focus) ->
    @drawBackground focus
    super focus

myStars = new CategoryStars

d3.csv "data.csv", (data) ->
  myStars.draw data
