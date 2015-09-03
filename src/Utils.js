"use strict";

// module Utils

exports.htmlElementToCanvasImageSourceImpl = function (el, Just, Nothing) {
    if (el && el instanceof HTMLImageElement) {
        return Just(el);
    } else {
        return Nothing;
    }
};

exports.querySelectorImpl = function (selector, Just, Nothing) {
    return function () {
        var el = document.querySelector(selector);
        return el ? Just(el) : Nothing;
    }
}

exports.getFileImpl = function (el, Just, Nothing) {
    return function () {
        return el.file[0] ? Just(el.file[0]) : Nothing;
    }
}

exports.fileName = function (file) {
    return function () {
        return file.name;
    }
}

exports.fileType = function (file) {
    return function () {
        return file.type;
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
