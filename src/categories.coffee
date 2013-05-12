# language visualizations

class CategoryStars extends LanguageGraphMatrix
  type: (d) -> types[d.lang]

  drawBackground: (focus) ->
    @rect(focus).attr("class", @type)

  render: (focus) ->
    @drawBackground focus
    super focus
