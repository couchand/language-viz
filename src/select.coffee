# selectable star

class SelectableStar extends LanguageGraph
  constructor: (w, h) ->
    w ?= 250
    h ?= 250
    super w, h

  createCanvas: ->
    @canvas = smallMultiples d3.select(@container),
      width: @width
      height: @height
      margin:
        left: 10
        right: 10
        top: 10
        bottom: 10

  selectLanguage: (lang) ->
    @canvas.datum
      lang: lang

  drawDots: (focus) ->
    t = @
    focus.selectAll(".benchmark")
      .data(@data)
      .enter().append("circle")
      .classed("benchmark", -> yes)
      .attr("r", 1.5)
      .attr("fill", "#d88")
      .attr("opacity", .6)
      .attr "transform", (d) ->
        return if isNaN t.getX d or isNaN t.getY d
        "translate(#{t.getX0 d},#{t.getY0 d})"

  drawList: ->
    t = @
    d3.select(@container).append("ul").selectAll("li")
      .data(a for a of @averages)
      .enter().append("li")
      .text((d) -> d)
      .on "mouseover", (d) ->
        t.selectLanguage d
        t.canvas.select('.star').remove()
        t.drawStar t.canvas

  draw: (data) ->
    @initialize data

    focus = @createCanvas()
    @selectLanguage "JavaScript V8"

    @drawDots focus
    @drawStar focus
    @drawList()

myStar = new SelectableStar()

myStar.container = "#selectable"

d3.csv "data.csv", (data) ->
  myStar.draw data
