class_name PaletteMap
extends Node

# Palette maps remap palette colors (only for palette 0?)

const MAX_COLORS:int = 256

var palette_maps:Array = []

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
