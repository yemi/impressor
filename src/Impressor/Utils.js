"use strict";

// module Impressor.Utils

exports.querySelectorImpl = function (selector, Just, Nothing) {
    return function () {
        var el = document.querySelector(selector);
        return el ? Just(el) : Nothing;
    }
}

exports.getImageSize = function (img) {
    return function () {
        return { w: img.naturalWidth, h: img.naturalHeight };
    };
};

exports.canvasToDataURL_ = function (type) {
    return function (encoderOptions) {
        return function (canvas) {
            return function () {
                return canvas.toDataURL(type, encoderOptions);
            };
        };
    };
};

// From https://gist.github.com/fupslot/5015897 and http://stackoverflow.com/a/16245768/1584052
exports.unsafeDataUrlToBlob = function (dataURL) {
    var byteString = atob(dataURL.split(',')[1]);
    var mimeString = dataURL.split(',')[0].split(':')[1].split(';')[0]
    var sliceSize = 512;
    var byteArrays = [];

    for (var offset = 0; offset < byteString.length; offset += sliceSize) {
        var slice = byteString.slice(offset, offset + sliceSize);
        var byteNumbers = new Array(slice.length);

        for (var i = 0; i < slice.length; i++) {
            byteNumbers[i] = slice.charCodeAt(i);
        }

        var byteArray = new Uint8Array(byteNumbers);
        byteArrays.push(byteArray);
    }

    var blob = new Blob(byteArrays, { type: mimeString });
    return blob;
}

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
