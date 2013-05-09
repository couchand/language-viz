# language visualizations

d3.csv 'languages.csv', (data) ->
  d3.select('#viz').selectAll('.dot')
    .data(data)
    .enter().append('div')
    .classed('dot', -> yes)
    .text (d) ->
      """
      Language: #{d.lang}
      Benchmark: #{d.name}
      """
