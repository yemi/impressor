"use strict";

var impress = require("impressor").Impressor.impress;

// Sugar for impressor function call
global.impressor = function (img, sizes, cb) {
  impress(img)(sizes)(function (imgs){
    return function () {
      cb(imgs);
    }
  })()
};
