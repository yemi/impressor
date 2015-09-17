"use strict";

// module Impressor.Workers

var work = require("webworkify");
var downScaleImageWorker = require("../js/down-scale-image-worker");
var worker = work(downScaleImageWorker);

exports.downScaleImageWorkerImpl = function (callback) {
  return function (scale) {
    return function (srcImageData) {
      return function (blankTargetImageData) {
        return function () {
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
