# language visualizations

class AllStars extends LanguageGraphMatrix
  constructor: (w, h) ->
    w ?= 100
    h ?= 100
    super w, h

  render: (focus) ->
    @drawDots focus
    super focus
