/* jshint node: true */
"use strict";

var gulp = require("gulp");
var purescript = require("gulp-purescript");
var uglify = require("gulp-uglify");
var source = require('vinyl-source-stream');
var browserify = require("browserify");
var shim = require('browserify-shim');

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

gulp.task("prebundle", ["make"], function () {
  return purescript.pscBundle({
    src: "output/**/*.js",
    output: "dist/impressor.js",
    module: "Impressor"
  });
});

gulp.task("bundle", function () {
  browserify({
    entries: "./entry.js",
    shim: {
      impressor: {
        path: "./dist/impressor.js",
        exports: "PS"
      }
    }
  })
    .bundle()
    .pipe(source("impressor-bundle.js"))
    .pipe(gulp.dest("./dist"));
});

gulp.task("compress", ["prebundle"], function () {
  return gulp.src("dist/impressor.js")
    .pipe(uglify())
    .pipe(gulp.dest("dist"));
})

gulp.task("default", ["prebundle"]);
