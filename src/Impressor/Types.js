"use strict";

// module Impressor.Types

exports.elementToCanvasElement = function (el) {
    return el;
};

exports.htmlElementToCanvasImageSourceImpl = function (el, Just, Nothing) {
    if (el && el instanceof HTMLImageElement) {
        return Just(el);
    } else {
        return Nothing;
    }
};
