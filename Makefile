# build the examples

examples: pages scripts

pages: www/index.html
scripts: www/languages.js

www/index.html: src/index.haml
	haml src/index.haml > www/index.html

www/languages.js: src/languages.coffee
	coffee -c -o www src/languages.coffee
