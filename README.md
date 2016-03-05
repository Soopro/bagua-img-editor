# Bagua Image Editor

A Image Editor for resize and crop images and return dataurl or blob or a recipe for CDN usage. No file upload funciton at all.

###  Usage

Html editor:
```
<div sup-image-editor></div>
```

Angular directive :
```
<div sup-image-editor options="{'cors':'false'}"
     img-src-url="image_src" img-recipe="media.recipe"></div>
```

### Options

* img-src-url: image src
* img-recipe: A recipe return by `recipe()`. it's for restore the crop area.
* options
  * corner_size: **[ int ]** corner size in px, default is 12
  * crop_min_size: **[ int ]** minimal corp size in px, default is 32
  * cors: true: **[ bool ]** cross orgian support for `<img>`

### Functions

* init: init editor
  1. editor: **[ str ]** for the div `name` or **[ htmlElement ]** for the div.
  2. opt: **[ int ]** (optional) options will update default options.
  3. is_debug: **[ bool ]** (optional) start with debug.

* load: load image
  1. img_src: **[ str ]** image src, could use `dataurl`.
  2. recipe: **[ dict ]** (optional) recipe create by this editor, returned by function `recipe()`.
  
* unload: unload editor, clean up image and listeners, ready to reload.

* recipe: return a recipe, it cloud be work with cdn resize/crop.

* mimetype: get image mimetype.

* scale: scale image
  1. aspect_ratio: percent of image resize.

* capture: capture image and return a Dataurl.
  1. mimetype: (optional) image mimetype, if not give editor make a guess.
  2. encoder: (optional) encoder for the image quality, jpg only.

* capture_blob: capture image and return a blob.
  1. media: **[ dict ]** (optional) media information. must has: `type`, `name`, `media.lastModified`, `media.lastModifiedDate`.
  2. encoder: **[ float ]** (optional) encoder for the image quality, jpg only.

* blob: complie dataurl to blob.
  1. media: **[ dict ]** (optional) media information. must has: `type`, `name`, `media.lastModified`, `media.lastModifiedDate`.
  2. dateurl: **[ dateurl ]** media file with data url format.

* destroy: destroy editor clean up everything.

* hooks:
  1. loaded: register hook for loaded
    
Angular directive might not need: `init`, `load`, `unload`, `hooks`, `destory`