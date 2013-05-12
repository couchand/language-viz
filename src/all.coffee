# run all viz

myStar = new SelectableStar()
myStar.container = "#selectable"

hisStars = new LambdaStars()
hisStars.container = "#lambdas"

myStars = new CategoryStars()
myStars.container = "#categories"

d3.csv "data.csv", (data) ->
  myStar.draw data
  hisStars.draw data
  myStars.draw data
