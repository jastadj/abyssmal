class_name IndexedImage
extends Node

enum IMAGE_FORMAT{FMT_8BIT = 4, FMT_4BIT_RLE = 8, FMT_5BIT_RLE = 6, FMT_4BIT = 10, INVALID = 99}

var palette_index:int = 0
var aux_palette:int = -1
var dims := Vector2i()
var data:Array = []
var texture:ImageTexture = null
var format:IMAGE_FORMAT = IMAGE_FORMAT.INVALID

func generate_texture() -> ImageTexture:
	var img:Image = Image.create(dims.x, dims.y, false, Image.FORMAT_RGBA8)
	for y in range(dims.y):
		for x in range(dims.x):
			var r:float = float(data[(y*dims.x) + x]) / 255.0
			img.set_pixel(x, y, Color(r, 0, 0, 1))
	var new_texture:ImageTexture = ImageTexture.create_from_image(img)
	texture = new_texture
	return texture

func uses_auxpalette() -> bool:
	return aux_palette >= 0 and (format == IndexedImage.IMAGE_FORMAT.FMT_4BIT or format == IndexedImage.IMAGE_FORMAT.FMT_4BIT_RLE)
