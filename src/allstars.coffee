# language visualizations

class AllStars extends LanguageGraphMatrix
  constructor: (w, h) ->
    w ?= 100
    h ?= 100
    super w, h
    @margin.left = 30
    @margin.right = 30

  render: (focus) ->
    @drawDots focus
    super focus
