"use strict";

// module Impressor.Workers

exports.downScaleImageWorkerImpl = function (callback) {
  return function (scale) {
    return function (srcImageData) {
      return function (blankTargetImageData) {
        return function () {
          var worker = new Worker("/dist/worker.js");
          worker.postMessage({
            scale: scale,
            srcImageData: srcImageData,
            blankTargetImageData: blankTargetImageData
          });
          worker.onmessage = function (e) {
            callback(e.data)();
          }
        }
      }
    }
  }
}
