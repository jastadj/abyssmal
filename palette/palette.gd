class_name Palette
extends Node

var palettes:Array = []

static func load_from_binary(filepath:String) -> Palette:
	var pal:Palette = null
	print("Loading Palette (256 Colors) from ", filepath)
	var data:PackedByteArray = FileAccess.get_file_as_bytes(filepath)
	if !data.is_empty():
		# expected size?
		if data.size() % (3 * 256):
			printerr("Unexpected palette data size.")
			return pal
		var pal_count:int = data.size() / 3 / 256
		pal = Palette.new()
		
		for i in range(pal_count):
			pal.palettes.append([])
			for n in range(256):
				pal.palettes[i].append(Color(data[(i*256) + n + 0], data[(i*256) + n + 1], data[(i*256) + n + 2]))
		print("Palette (256 Colors) loaded from ", filepath, ", size: ", data.size(), ", palettes: ", pal.palettes.size())
	return pal
