# language visualizations

class CategoryStars extends LanguageGraphMatrix
  type: (d) -> types[d.lang]

  drawBackground: (focus) ->
    @rect(focus).attr("class", @type)

  render: (focus) ->
    @drawBackground focus
    super focus

myStars = new CategoryStars
myStars.container = "#categories"

d3.csv "data.csv", (data) ->
  myStars.draw data
