// Generated by CoffeeScript 1.4.0
var smallMultiples;

smallMultiples = function(container, options) {
  var clip, fh, focus, fw, h, ml, mt, svg, td, ts, w;
  w = options.width || 0;
  w += options.margin.left || 0;
  w += options.margin.right || 0;
  h = options.height || 0;
  h += options.margin.top || 0;
  h += options.margin.bottom || 0;
  h += options.title.size || 0;
  h += options.title.padding || 0;
  ml = options.margin.left || 0;
  mt = options.margin.top || 0;
  mt += options.title.height || 0;
  mt += options.title.padding || 0;
  fw = options.width || 0;
  fh = options.height || 0;
  ts = options.title.size || 0;
  td = options.title.data || function() {
    return '';
  };
  svg = container.selectAll("svg").data(function(d) {
    return d;
  }).enter().append("svg").attr("width", w).attr("height", h).append("g").attr("transform", "translate(" + ml + "," + mt + ")");
  svg.append("title").text(td);
  svg.append("text").attr("x", fw / 2).attr("y", -4).style("font-size", ts).attr("text-anchor", "middle").text(td);
  clip = svg.append("defs").append("clipPath").attr("id", function(d, i) {
    return "clip" + i;
  }).append("rect").attr("width", fw).attr("height", fh);
  return focus = svg.append("g").attr("clip-path", function(d, i) {
    return "url(#clip" + i + ")";
  });
};
