let gulp = require('gulp');
let minifycss = require('gulp-clean-css');
let uglify = require('gulp-uglify');
let htmlmin = require('gulp-htmlmin');
let htmlclean = require('gulp-htmlclean');
let imagemin = require('gulp-imagemin');
var pump = require('pump');

gulp.task('minify-css', function () {
    return gulp.src('./public/**/*.css').pipe(minifycss()).pipe(gulp.dest('./public'));
});

gulp.task('minify-html', function () {
    return gulp.src('./public/**/*.html').pipe(htmlclean()).pipe(htmlmin()).pipe(gulp.dest('./public'))
});

gulp.task('minify-js', function (cb) {
	pump([
        gulp.src('./public/**/*.js'),
        uglify(),
        gulp.dest('./public')
    ],
    cb
  );
});


gulp.task('minify-image', function () {
    return gulp.src('./public/**/*.{png,jpg,gif,ico,svg,jpeg}').pipe(imagemin()).pipe(gulp.dest('./public'));
});

gulp.task('default', ['minify-html', 'minify-css', 'minify-image']);