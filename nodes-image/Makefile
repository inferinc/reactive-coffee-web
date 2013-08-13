all: index.html main.js random-js/random.js
%.js: %.coffee
	coffee -b -c $<
%.html: %.jade
	jade $<
