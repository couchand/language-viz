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

  languages: ->
    ls = (a for a of @averages)
    ls.sort()
    ls

  drawList: ->
    t = @
    d3.select(@container).append("ul").selectAll("li")
      .data(@languages())
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
