# language visualizations

class LambdaStars extends LanguageGraphMatrix
  typeColor: d3.scale.ordinal()
      .domain(['lambda', 'c', 'other'])
      .range(['#7f8', '#8cf', '#ccc'])

  background: ->
    t = @
    (d) -> t.typeColor lambdas[d.lang]

  drawBackground: (focus) ->
    @rect(focus).attr("fill", @background())

  render: (focus) ->
    @drawBackground focus
    super focus

hisStars = new LambdaStars
hisStars.container = "#lambdas"

d3.csv "data.csv", (data) ->
  hisStars.draw data
