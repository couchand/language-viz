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

  drawStar: (focus) ->
    @star ?= super(focus)
    @star.classed 'selected', (d) ->
      d.lang is @selected_lang

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

  draw: (data) ->
    @initialize data

    focus = @createCanvas()
    @selectLanguage "JavaScript V8"

    @drawDots focus
    @drawStar focus

myStar = new SelectableStar()

d3.csv "data.csv", (data) ->
  myStar.draw data
