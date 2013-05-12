# build the examples

examples: data pages styles scripts resources blog

data: www/data.csv
pages: www/index.html
styles: www/style.css
scripts: www/languages.js www/smallMultiples.js
resources: www/types.js www/lambdas.js
blog: www/blog.js www/blog.html www/blog_test.html

www/data.csv:
	curl http://benchmarksgame.alioth.debian.org/u32/summarydata.php > t.html
	grep "name,lang,id" t.html | sed "s/<\/\?p>//g" | sed "s/<br\/>/\n/g" > www/data.csv
	sed -i "/^$$/d" www/data.csv

www/index.html: src/index.haml
	haml src/index.haml > www/index.html

www/style.css: src/style.sass
	sass src/style.sass www/style.css

www/languages.js: src/graph.coffee src/matrix.coffee src/describe.coffee src/select.coffee src/allstars.coffee src/lambda.coffee src/categories.coffee src/all.coffee
	coffee -c -o www -j languages src/graph.coffee src/matrix.coffee src/describe.coffee src/select.coffee src/allstars.coffee src/lambda.coffee src/categories.coffee src/all.coffee

www/smallMultiples.js: src/smallMultiples.coffee
	coffee -cb -o www src/smallMultiples.coffee

www/types.js: src/types.coffee
	coffee -cb -o www src/types.coffee

www/lambdas.js: src/lambdas.coffee
	coffee -cb -o www src/lambdas.coffee

www/blog.js: src/blog.litcoffee
	coffee -c -o www src/blog.litcoffee

www/blog.html: src/blog.litcoffee
	docco src/blog.litcoffee -l classic -o www

www/blog_test.html: src/blog_test.haml
	haml src/blog_test.haml > www/blog_test.html
