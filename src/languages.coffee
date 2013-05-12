# language visualizations

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
