/* jshint node: true */
"use strict";

var gulp = require("gulp");
var purescript = require("gulp-purescript");
var webpack = require("webpack-stream");
var uglify = require("gulp-uglify");

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
    module: ["Impressor", "Utils", "Types"]
  });
});

gulp.task("bundle", ["prebundle"], function () {
  return gulp.src("dist/impressor.js")
    .pipe(webpack({
      resolve: { modulesDirectories: ["node_modules"] },
      output: { filename: "impressor.js" }
    }))
    .pipe(gulp.dest("dist"));
});

gulp.task("compress", ["bundle"], function () {
  return gulp.src("dist/impressor.js")
    .pipe(uglify())
    .pipe(gulp.dest("dist"));
})

gulp.task("default", ["prebundle"]);
