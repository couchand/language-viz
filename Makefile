# build the examples

examples: pages styles scripts

pages: www/index.html
styles: www/style.css
scripts: www/languages.js

www/index.html: src/index.haml
	haml src/index.haml > www/index.html

www/style.css: src/style.sass
	sass src/style.sass www/style.css

www/languages.js: src/languages.coffee
	coffee -c -o www src/languages.coffee
