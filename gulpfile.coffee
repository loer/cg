gulp = require 'gulp'
stylus = require 'gulp-stylus'
coffee = require 'gulp-coffee'
coffeelint = require 'gulp-coffeelint'
coffeeify = require 'coffeeify'
nano = require 'gulp-cssnano'
uglify = require 'gulp-uglify'
del = require 'del'
gutil = require 'gulp-util'
plumber = require 'gulp-plumber'
livereload = require 'gulp-livereload'
sourcemaps  = require 'gulp-sourcemaps'
koutoSwiss = require 'kouto-swiss'
connect = require 'gulp-connect'
browserify = require 'browserify'
source = require 'vinyl-source-stream'
buffer = require 'vinyl-buffer'
concat = require 'gulp-concat'
hbsfy = require 'hbsfy'

project =
	name: 'cg'
	scriptEntry: 'src/scripts/main.coffee'
	scripts: 'src/scripts/**/*.coffee'
	styles: 'src/styles/**/*.styl'
	templates: 'src/**/*.html'
	hbs: 'src/hbs/**/*.hbs'
	js: 'src/**/*.js'
	images: 'src/images/**/*'
	dist: 'build/**/*'
	folders:
		root:
			folder: 'src'
		dist: 
			folder: 'build'
			scripts: 'build/scripts'
			images: 'build/images'
			styles: 'build/styles'

gulp.task 'clean', (cb) ->
	del 'build', cb

gulp.task 'styles', ->
	gulp.src project.styles
		.pipe plumber()
		.pipe stylus
			'use': koutoSwiss()
		.pipe nano
			autoprefixer: 
				browsers: 'last 2 versions'
				add: true
		.pipe gulp.dest project.folders.dist.styles

gulp.task 'lint:coffee', ->
	gulp.src project.scripts
		.pipe plumber()
		.pipe coffeelint
			max_line_length: 
				level: 'ignore'
			no_tabs:
				level: 'ignore'
			indentation:
				value: 1
		.pipe coffeelint.reporter()

gulp.task 'scripts', ['lint:coffee'], ->
	browserify
		entries: ['./src/scripts/main.coffee']
		extensions: ['.coffee', '.js']
	.transform coffeeify
	.transform hbsfy
	.bundle()
	.pipe source 'main.js'
	.pipe buffer()
    .pipe(sourcemaps.init({loadMaps: true}))
        .pipe(uglify())
        .on('error', gutil.log)
    .pipe(sourcemaps.write('./'))
	.pipe gulp.dest project.folders.dist.scripts

gulp.task 'js', ->
	gulp.src project.js
		.pipe gulp.dest project.folders.dist.folder

gulp.task 'templates', ->
	gulp.src project.templates
		.pipe gulp.dest project.folders.dist.folder

gulp.task 'images', ->
	gulp.src project.images
		.pipe gulp.dest project.folders.dist.images

gulp.task 'build', ->
	gulp.start 'styles', 'scripts', 'images', 'templates', 'js'

gulp.task 'dev', ['build', 'serve', 'watch'], ->
	gutil.log "#{ gutil.colors.cyan '------------------------------------------------------------' }"
	gutil.log "Local webserver is started. Watching for file changes"
	gutil.log "#{ gutil.colors.cyan '------------------------------------------------------------' }"

gulp.task 'watch', ->
	gulp.watch [project.styles, project.scripts, project.templates, project.hbs], ['preview']

gulp.task 'serve', ->
	connect.server
		name: 'Creuna Gallery'
		root: project.folders.dist.folder
		port: 8080
		livereload: true

gulp.task 'preview', ['styles', 'scripts', 'images', 'templates'], ->
	gulp.src project.dist
		.pipe connect.reload()

gulp.task 'default', ->
	gutil.log "#{ gutil.colors.cyan '------------------------------------------------------------' }"
	gutil.log "No default task, use #{ gutil.colors.green 'gulp <task>' } instead"
	gutil.log "#{ gutil.colors.cyan '------------------------------------------------------------' }"
	gutil.log "#{ gutil.colors.bgGreen 'Development Tasks available:' }"
	gutil.log "#{ gutil.colors.green 'gulp clean' } to remove previously built files"
	gutil.log "#{ gutil.colors.green 'gulp styles' } to only build styles"
	gutil.log "#{ gutil.colors.green 'gulp scripts' } to only build scripts"
	gutil.log "#{ gutil.colors.green 'gulp images' } to only process images"
	gutil.log "#{ gutil.colors.green 'gulp build' } to execute a complete build"
	gutil.log "#{ gutil.colors.green 'gulp dev' } to initiate the watchers for local development and live reload"
	gutil.log "#{ gutil.colors.cyan '------------------------------------------------------------' }"
