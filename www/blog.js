// Generated by CoffeeScript 1.6.2
(function() {
  var createCanvas, height, margin, width;

  width = 250;

  height = 250;

  margin = 100;

  d3.csv("data.csv", function(data) {
    var average, averages, benchmarks, best, d, focus, language_list, languages, mins, name, scaleX, scaleY, showLanguageStar, star, x, y, _i, _j, _len, _len1;

    for (_i = 0, _len = data.length; _i < _len; _i++) {
      d = data[_i];
      d["cpu(s)"] = parseFloat(d["cpu(s)"]);
      d["size(B)"] = parseFloat(d["size(B)"]);
    }
    best = d3.nest().key(function(d) {
      return d.name;
    }).rollup(function(v) {
      return {
        "cpu(s)": d3.min(v, function(d) {
          return d["cpu(s)"];
        }),
        "size(B)": d3.min(v, function(d) {
          return d["size(B)"];
        })
      };
    });
    mins = best.map(data);
    for (_j = 0, _len1 = data.length; _j < _len1; _j++) {
      d = data[_j];
      d["cpu(s)"] = d["cpu(s)"] / mins[d.name]["cpu(s)"];
      d["size(B)"] = d["size(B)"] / mins[d.name]["size(B)"];
    }
    scaleX = d3.scale.sqrt().domain([1, 5000]).rangeRound([0, width]);
    scaleY = d3.scale.sqrt().domain([1, 6]).rangeRound([height, 0]);
    x = function(d) {
      return scaleX(d["cpu(s)"]);
    };
    y = function(d) {
      return scaleY(d["size(B)"]);
    };
    focus = createCanvas();
    focus.selectAll(".benchmark").data(data).enter().append("circle").attr("class", "benchmark").attr("r", 2).attr("transform", function(d) {
      return "translate(" + (x(d)) + "," + (y(d)) + ")";
    });
    average = d3.nest().key(function(d) {
      return d.lang;
    }).rollup(function(v) {
      return {
        "cpu(s)": d3.mean(v, function(d) {
          return d["cpu(s)"];
        }),
        "size(B)": d3.mean(v, function(d) {
          return d["size(B)"];
        })
      };
    });
    averages = average.map(data);
    benchmarks = d3.nest().key(function(d) {
      return d.lang;
    }).map(data);
    star = focus.append("g").attr("class", "star");
    showLanguageStar = function(lang) {
      var avg, lines;

      avg = averages[lang];
      star.transition().attr("transform", "translate(" + (x(avg)) + "," + (y(avg)) + ")");
      lines = star.selectAll("line").data(benchmarks[lang]);
      lines.enter().append("line");
      lines.transition().attr("x2", function(d) {
        return x(d) - x(avg);
      }).attr("y2", function(d) {
        return y(d) - y(avg);
      });
      return lines.exit().remove();
    };
    showLanguageStar("JavaScript V8");
    language_list = (function() {
      var _results;

      _results = [];
      for (name in averages) {
        _results.push(name);
      }
      return _results;
    })();
    language_list.sort();
    languages = d3.select("body").append("ul").selectAll("li").data(language_list).enter().append("li").text(function(d) {
      return d;
    });
    return languages.on("mouseover", showLanguageStar);
  });

  createCanvas = function() {
    var svg;

    svg = d3.select("body").append("svg").attr("width", width + 2 * margin).attr("height", height + 2 * margin).append("g").attr("transform", "translate(" + margin + "," + margin + ")");
    svg.append("defs").append("clipPath").attr("id", "clip").append("rect").attr("width", width).attr("height", height);
    return svg.append("g").attr("clip-path", "url(#clip)");
  };

}).call(this);
