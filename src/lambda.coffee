# language visualizations

class LambdaStars extends LanguageGraphMatrix
  type: (d) -> lambdas[d.lang]

  drawBackground: (focus) ->
    @rect(focus).attr("class", @type)

  render: (focus) ->
    @drawBackground focus
    super focus
