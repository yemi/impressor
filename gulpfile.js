"use strict";

var gulp = require("gulp");
var purescript = require("gulp-purescript");
var uglify = require("gulp-uglify");
var source = require("vinyl-source-stream");
var browserify = require("browserify");
var insert = require("gulp-insert");

var sources = [
  "src/**/*.purs",
  "bower_components/purescript-*/src/**/*.purs"
];

var foreigns = [
  "bower_components/purescript-*/src/**/*.js",
  "src/**/*.js"
];

gulp.task("make", function () {
  return purescript.psc({ src: sources, ffi: foreigns });
});

gulp.task("pscBundle", ["make"], function () {
  return purescript.pscBundle({
    src: "output/**/*.js",
    output: "dist/impressor.js",
    module: "Impressor"
  })
});

gulp.task("exportPscBundle", ["pscBundle"], function () {
  return gulp.src("dist/impressor.js")
    .pipe(insert.append("module.exports = PS;"))
    .pipe(gulp.dest("dist"));
});

gulp.task("bundle", ["exportPscBundle"], function () {
  return browserify({
    entries: "entry.js",
    standalone: "Impressor"
  })
    .bundle()
    .pipe(source("impressor.js"))
    .pipe(gulp.dest("dist"));
});

gulp.task("minify", ["bundle"], function () {
  return gulp.src("dist/impressor.js")
    .pipe(uglify())
    .pipe(gulp.dest("dist"));
})

gulp.task("default", ["bundle"]);
