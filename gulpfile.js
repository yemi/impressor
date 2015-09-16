/* jshint node: true */
"use strict";

var gulp = require("gulp");
var purescript = require("gulp-purescript");
var uglify = require("gulp-uglify");
var source = require("vinyl-source-stream");
var browserify = require("browserify");
var insert = require("gulp-insert");
var runSequence = require("run-sequence");

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

gulp.task("prebundle", function () {
  return purescript.pscBundle({
    src: "output/**/*.js",
    output: "dist/impressor.js",
    module: "Impressor"
  })
});

gulp.task("exportPrebundle", function () {
  return gulp.src("dist/impressor.js")
    .pipe(insert.append("module.exports = PS;"))
    .pipe(gulp.dest("dist"))
});

gulp.task("bundle", function () {
  return browserify({
    entries: "entry.js",
    standalone: "Impressor"
  })
    .bundle()
    .pipe(source("impressor.js"))
    .pipe(gulp.dest("dist"));
});

gulp.task("compress", function () {
  return gulp.src("dist/impressor.js")
    .pipe(uglify())
    .pipe(gulp.dest("dist"));
})

gulp.task("default", function () {
  runSequence("make", "prebundle", "exportPrebundle", "bundle");
});
