"use strict";

// module Impressor.Workers

// var Work = require('worker!../js/downScaleImageWorker.js');
// var worker = new Work();
var work = require('webworkify');
var worker = work(require('../workers/downScaleImageWorker.js'));

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
