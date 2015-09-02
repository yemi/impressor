"use strict";

// module Utils

exports.getCanvasImageSourceByIdImpl = function (id, Just, Nothing) {
    return function() {
        var el = document.getElementById(id);
        if (el && el instanceof HTMLImageElement) {
            return Just(el);
        } else {
            return Nothing;
        }
    };
};

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
