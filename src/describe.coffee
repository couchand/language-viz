# selectable star

class DescriptionGraph extends LanguageGraph
  constructor: (w, h) ->
    w ?= 200
    h ?= 200
    super w, h

  createCanvas: ->
    @canvas = smallMultiples d3.select(@container),
      width: @width
      height: @height
      margin:
        left: 40
        right: 40
        top: 20
        bottom: 20

  drawWords: (focus) ->
    @word focus, "Ideal",     "ideal",    10,        @height+25
    @word focus, "System",    "system",   20,        50
    @word focus, "Script",    "script",   @width-10, @height
    @word focus, "Obselete",  "obselete", @width-25, 40
    @word focus, "slowness",  "axes",     @width+10, @height+35
    @word(focus, "code size", "axes",     40,        70)
      .attr "transform", "rotate(-90 40,70)"

  word: (focus, w, c, x, y) ->
    focus.append("text")
      .attr("x", x)
      .attr("y", y)
      .classed(c, -> yes)
      .text(w)

  draw: (data) ->
    @initialize data

    focus = @createCanvas()

    @drawDots focus
    @drawWords d3.select(@container).select "svg"
