"use strict";

// module Utils

exports.getImageById = function(id) {
    return function() {
        return document.getElementById(id);
    }
};

exports.getImageDimensions = function (img) {
    return function () {
        return { w: img.naturalWidth, h: img.naturalHeight };
    }
};
