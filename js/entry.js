"use strict";

var impress = require("./psc-bundle").Impressor.impress;

// Sugar for Impressor function call
var Impressor = function (img, sizes, cb) {
  impress(img)(sizes)(function (imgs){
    return function () {
      cb(imgs);
      return;
    }
  })();
};

module.exports = Impressor;
