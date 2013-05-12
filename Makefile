# build the examples

examples: data pages styles scripts

data: www/data.csv
pages: www/index.html
styles: www/style.css
scripts: www/languages.js www/smallMultiples.js www/types.js

www/data.csv:
	curl http://benchmarksgame.alioth.debian.org/u32/summarydata.php > t.html
	grep "name,lang,id" t.html | sed "s/<\/\?p>//g" | sed "s/<br\/>/\n/g" > www/data.csv

www/index.html: src/index.haml
	haml src/index.haml > www/index.html

www/style.css: src/style.sass
	sass src/style.sass www/style.css

www/languages.js: src/languages.coffee
	coffee -c -o www -j src/graph.coffee src/languages.coffee

www/smallMultiples.js: src/smallMultiples.coffee
	coffee -cb -o www src/smallMultiples.coffee

www/types.js: src/types.coffee
	coffee -cb -o www src/types.coffee
