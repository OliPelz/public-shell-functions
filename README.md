# public-shell-functions

* no dependencies
* works for both bash and zsh

* develop functions in `./src`
* dont use source command in those files
* if something depends on each other, make the dependency resolution by putting dependant files with lower numbers
* type `make compile` to concat and minify all script files
* use only compiled and minified `build/*` files for sourcing in external projects

NOTES: 
* functions in here MUST HAVE ZERO EXTERNAL DEPENDENCIES!!!
* no internal linking allowed, which means not sourcing any of the files in between
* if you need access from one files data or functions to another one internally, put the content together in ONE file
