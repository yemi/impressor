"use strict";

// module Impressor.Workers

var work = require('webworkify-webpack');
var downScaleImageWorker = require('../js/downScaleImageWorker.js')

exports.downScaleImageWorkerImpl = function (callback) {
  return function (scale) {
    return function (srcImageData) {
      return function (blankTargetImageData) {
        return function () {
          var worker = work(downScaleImageWorker);

          worker.postMessage({
            scale: scale,
            srcImageData: srcImageData,
            blankTargetImageData: blankTargetImageData
          });

          worker.onmessage = function (ev) {
            callback(ev.data)();
          };
        }
      }
    }
  }
}
