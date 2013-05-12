d3 language graphs a la marceau
===============================

The other day I came across [this blog post][marceau] from
Guillaume Marceau graphing data from the
[Computer Language Benchmarks Game][benchmarks].  My first thought
was, "cool".  My next was, "I should update this with recent data
and d3".

[marceau]: http://blog.gmarceau.qc.ca/2009/05/speed-size-and-dependability-of.html "The speed, size and dependability of programming languages"
[benchmarks]: http://benchmarksgame.alioth.debian.org/ "The Computer Language Benchmarks Game"

    graph = (data) ->

So let's navigate over to the Benchmarks Game website and download
the summary data.  The first thing we notice is that the csv reports
absolute numbers, but Marceau graphs relative ones, the number of
times larger or longer running a program is than the best solution.

It's easy enough to ask d3 to do this conversion for us.

        best = d3.nest()
            .key((d) -> d.name)
            .rollup (v) ->
                "cpu(s)":  d3.min v, (d) -> d["cpu(s)"]
                "size(B)": d3.min v, (d) -> d["size(B)"]
    
        mins = best.map data
    
        for d in data
            d["cpu(s)"]  = d["cpu(s)"]  / mins[d.name]["cpu(s)"]
            d["size(B)"] = d["size(B)"] / mins[d.name]["size(B)"]

Great.  Now we draw a basic scatter plot.  The boilerplate has been
omitted here, take a look at the git repo for more complete code.

        scaleX = d3.scale.sqrt().domain([0, 5000]).rangeRound([0,  width])
        scaleY = d3.scale.sqrt().domain([1,    6]).rangeRound([height, 0])
    
        x = (d) -> scaleX d["cpu(s)"]
        y = (d) -> scaleY d["size(B)"]
    
        focus.selectAll(".benchmark")
            .data(data)
            .enter().append("circle")
            .attr("class", "benchmark")
            .attr("r", 2)
            .attr "transform", (d) ->
                "translate(#{x d},#{y d})"

On top of the scatter plot we want to draw a star.  The center of the
star is the average of the benchmarks, so first we'll rollup the
benchmark data.

        average = d3.nest()
            .key((d) -> d.lang)
            .rollup (v) ->
                "cpu(s)":  d3.min v, (d) -> d["cpu(s)"]
                "size(B)": d3.min v, (d) -> d["size(B)"]
    
        averages = average.map data

We'll only show the star for the currently selected language, so
let's sort the benchmark results by language.

        benchmarks = d3.nest()
            .key((d) -> d.lang)
            .map data

Now we have everything we need to draw the star for some language.
First we move add the group and move it into position.

        setLanguage = (lang) ->
            avg = averages[lang]
    
            star = focus.append("g")
                .attr("class", "star")
                .attr("transform", "translate(#{x avg},#{y avg})")

Then we append a spoke to the group for each benchmark of the
selected language.

            star.selectAll("path")
                .data( benchmarks[lang] )
                .enter().append("path")
                .attr "d", (d) ->
                    "M 0,0 L #{x(d) - x(avg)},#{y(d) - y(avg)}"
    
We set the default language on page load.

        setLanguage "JavaScript V8"

Finally we need a list of languages to select from.

        d3.select("body").append("ul").selectAll("li")
            .data(languages)
            .enter().append("li")
            .text((d) -> d)
            .on "mouseover", setLanguage

boilerplate
-----------

the rest of this is the boilerplate.  it may not be sexy, but it is
important.

some constants.

    width = 250
    height = 250
    margin = 100

create the svg element and frame.

    svg = d3.select("body").append("svg")
        .attr("width", width + 2*margin)
        .attr("height", height + 2*margin)
        .append("g")
        .attr("transform", "translate(#{margin},#{margin})")

create a clip path for the frame.

    clip = svg.append("defs").append("clipPath")
        .attr("id", (d,i) -> "clip#{myCount}-#{i}")
        .append("rect")
        .attr("width", fw)
        .attr("height", fh)

create the focus element within the frame.

    focus = svg.append("g")
        .attr("clip-path", (d,i) -> "url(#clip#{myCount}-#{i})")

load the data and render the graph.

    d3.csv "data.csv", (data) ->
        graph data
