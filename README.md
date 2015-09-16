# Impressor

A client side image processing library using canvas. Takes an image, an array of image sizes and a callback function with the processed images as argument.

## Installation

**Bower**
```
bower install impressor
```
  
**Npm**
```
npm install impressor
```

## Usage
```javascript

var impressor = require("Impressor");
var image = document.querySelector(".img");
var sizes = [
  {
    width: 100,
    height: 100,
    name: "thumbnail"
  },
  {
    width: 1920,
    height: 600,
    name: "cover-image"
  },
  {
    width: 600,
    // Height is optional
    name: "blog-post"
  }
];

// Impressor processes images asynchronously
impressor(image, sizes, function (images) {
  console.log(images) // [{ name: "thumbnail", blob: Blob }, { name: "cover-image", blob: Blob }, {..}] 
});
```

## Contribution
```
$ npm install
$ bower install
$ gulp
```
