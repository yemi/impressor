"use strict"

var impress = require("./impressorPscBundle").Impressor.impress

// Sugar for Impressor function call
var impressor = function (img, sizes, cb) {
  impress(img)(sizes)(function (imgs) {
    return function () {
      cb(imgs)
      return
    }
  })()
}

module.exports = impressor

