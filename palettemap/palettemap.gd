class_name PaletteMap
extends Node

# Palette maps remap palette colors (only for palette 0?)

const MAX_COLORS:int = 256

var palette_maps:Array = []

var texture:ImageTexture = null

static func load_from_binary(filepath:String) -> PaletteMap:
	var palmap:PaletteMap = null
	print("Loading Palette Map from ", filepath)
	var data:PackedByteArray = FileAccess.get_file_as_bytes(filepath)
	if !data.is_empty():
		# calculate the number of palette maps in this file
		var map_count:int = data.size() / MAX_COLORS
		# create new palette map
		palmap = PaletteMap.new()
		# for each palette map
		for i in range(map_count):
			palmap.palette_maps.append([])
			# for each index
			for n in range(MAX_COLORS):
				palmap.palette_maps[i].append(data[(i*MAX_COLORS) + n])
		print("Palette Map loaded from ", filepath, ", size: ", data.size(), ", maps: ", palmap.palette_maps.size())
	if palmap == null:
		printerr("Error loading palette map from ", filepath)
	return palmap

# generates a texture where each line run is one palette, all palettes stacked
# each color stores the mapped index in the r component
func generate_texture(palette:Palette) -> bool:
	var result:bool = true
	var img:Image = Image.create(Palette.MAX_COLORS, palette_maps.size(), false, Image.FORMAT_RGBA8)
	texture = null
	if palette and !palette.palettes.is_empty():
		for y in range(palette_maps.size()):
			for x in range(Palette.MAX_COLORS):
				var r = float(palette_maps[y][x]) / 255.0
				img.set_pixel(x, y, Color(r, 0, 0))
		texture = ImageTexture.create_from_image(img)
		result = (texture != null)
	else: result = false
	if !result: texture = null
	return result
		
