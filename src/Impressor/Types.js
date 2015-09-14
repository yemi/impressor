"use strict";

// module Impressor.Types

exports.elementToCanvasElement = function (el) {
    return el;
};

exports.readCanvasImageSourceImpl = function (foreign, Left, Right) {
    if (foreign && foreign instanceof HTMLImageElement) {
        return Right(foreign);
    } else {
        return Left(foreign.toString() + " :: " + typeof foreign);
    }
};
