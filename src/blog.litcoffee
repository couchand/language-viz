d3 language graphs a la marceau
===============================

The other day I came across [this blog post][marceau] from Guillaume
Marceau graphing benchmark speed and size data from the
[Computer Language Benchmarks Game][benchmarks].

Given my interests in data visualization and programming languages,
it is no surprise that these graphs tickled me.  They are, however,
a little old, and Marceau's post leaves a few outstanding questions,
so I thought I'd try to recreate his findings.  And we may as well
use [d3][d3] for it.

[marceau]: http://blog.gmarceau.qc.ca/2009/05/speed-size-and-dependability-of.html "The speed, size and dependability of programming languages"
[benchmarks]: http://benchmarksgame.alioth.debian.org/ "The Computer Language Benchmarks Game"
[d3]: http://www.d3js.org "D3: Data-Driven Documents"

In this post I'll walk through building only one of Marceau's graphs,
but if you're interested checkout [this page][moreviz] for more.  Also
feel free to poke around the [git repo][github] for this project.

[moreviz]: http://couchand.github.io/language-viz "language graph examples"
[github]: http://www.github.com/couchand/language-viz "language-viz GitHub repository"

    width = 250
    height = 250
    margin = 100

Let's navigate over to the Benchmarks Game website and download
the summary data.  You can find it [here][data].

[data]: http://benchmarksgame.alioth.debian.org/u32/summarydata.php "Computer Language Benchmarks Game summary data"

    d3.csv "data.csv", (data) ->
        for d in data
            d["cpu(s)"]  = parseFloat d["cpu(s)"]
            d["size(B)"] = parseFloat d["size(B)"]

the scatter plot
-------------------

The first thing we notice is that the csv reports absolute numbers,
but Marceau graphs relative ones, the number of times larger or
longer running a program is than the best solution.  It's easy
enough to ask d3 to do this conversion for us.

        best = d3.nest()
            .key((d) -> d.name)
            .rollup (v) ->
                "cpu(s)":  d3.min v, (d) -> d["cpu(s)"]
                "size(B)": d3.min v, (d) -> d["size(B)"]

        mins = best.map data

Calculate the minimum size and time for each benchmark, then scale
the data accordingly.

        for d in data
            d["cpu(s)"]  = d["cpu(s)"]  / mins[d.name]["cpu(s)"]
            d["size(B)"] = d["size(B)"] / mins[d.name]["size(B)"]

Great.  Let's draw a basic scatter plot.  We'll scale the domain
manually to exclude the outliers.  Framing our plot this way
highlights an interesting fact about this data: other than those
outliers, the largest programs only take about six times the space
of the most optimum.  However, the slowest programs run for five
thousand times longer than the fastest.

        scaleX = d3.scale.sqrt().domain([0, 5000]).rangeRound([0,  width])
        scaleY = d3.scale.sqrt().domain([1,    6]).rangeRound([height, 0])

        x = (d) -> scaleX d["cpu(s)"]
        y = (d) -> scaleY d["size(B)"]

Now add a dot for each benchmark data point.  The x-coordinate is
the benchmark relative speed, and the y-coordinate the relative size.

        focus = createCanvas()

        focus.selectAll(".benchmark")
            .data( data )
            .enter().append("circle")
            .attr("class", "benchmark")
            .attr("r", 2)
            .attr "transform", (d) ->
                "translate(#{x d},#{y d})"

performance stars
-----------------

On top of the scatter plot we want to draw a star.  The center of the
star is the average of the benchmarks, so first we'll rollup the
benchmark data.

        average = d3.nest()
            .key((d) -> d.lang)
            .rollup (v) ->
                "cpu(s)":  d3.mean v, (d) -> d["cpu(s)"]
                "size(B)": d3.mean v, (d) -> d["size(B)"]

        averages = average.map data

We'll only show the star for the currently selected language, so
let's sort the benchmark results by language.

        benchmarks = d3.nest()
            .key((d) -> d.lang)
            .map data

Now we have everything we need to draw the star for some language.

        showLanguageStar = (lang) ->

First we get the average performance for this language.  We add an
svg group and move it to the average position.

            avg = averages[lang]

            focus.select(".star").remove()

            star = focus.append("g")
                .attr("class", "star")
                .attr("transform", "translate(#{x avg},#{y avg})")

Then we append a spoke for each benchmark data point of the
selected language.

            star.selectAll("path")
                .data( benchmarks[lang] )
                .enter().append("path")
                .attr "d", (d) ->
                    "M 0,0 L #{x(d) - x(avg)},#{y(d) - y(avg)}"

We set the default language on page load.

        showLanguageStar "JavaScript V8"

Finally we need a list of languages to select from.

        languages = (name for name of averages)

Whenever we mouseover the name of a language, call `showLanguageStar` to
redraw the star.

        d3.select("body").append("ul").selectAll("li")
            .data(languages)
            .enter().append("li")
            .text((d) -> d)
            .on "mouseover", showLanguageStar

boilerplate
-----------

Create an svg canvas with a little frame and clip path.

    createCanvas = ->

        svg = d3.select("body").append("svg")
            .attr("width", width + 2*margin)
            .attr("height", height + 2*margin)
            .append("g")
            .attr("transform", "translate(#{margin},#{margin})")

        svg.append("defs").append("clipPath")
            .attr("id", "clip")
            .append("rect")
            .attr("width", width)
            .attr("height", height)

        svg.append("g")
            .attr("clip-path", "url(#clip)")

