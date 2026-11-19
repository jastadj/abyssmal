class_name Palette
extends Node

# Palettes are 256 colors.
# Palette 0 is the main palette.
# Palette index 0 is always transparent

const MAX_COLORS:int = 256
const COMPS:int = 3

var palettes:Array = []

static func load_from_binary(filepath:String) -> Palette:
	const MAX_INTENSITY:int = 63
	var pal:Palette = null
	print("Loading Palette (256 Colors) from ", filepath)
	var data:PackedByteArray = FileAccess.get_file_as_bytes(filepath)
	if !data.is_empty():
		# calculate the number of palettes in this file
		var pal_count:int = data.size() / COMPS / MAX_COLORS
		# create new palette
		pal = Palette.new()
		# for each palette
		for i in range(pal_count):
			pal.palettes.append([])
			# for each palette color
			for n in range(MAX_COLORS):
				var r:int = clamp(data[(i*MAX_COLORS) + (n*COMPS) + 0], 0, MAX_INTENSITY)
				var g:int = clamp(data[(i*MAX_COLORS) + (n*COMPS) + 1], 0, MAX_INTENSITY)
				var b:int = clamp(data[(i*MAX_COLORS) + (n*COMPS) + 2], 0, MAX_INTENSITY)
				var a:float = 1.0
				if n == 0: a = 0.0 # index 0 is always transparent
				pal.palettes[i].append(Color(
						float(r)/float(MAX_INTENSITY),
						float(g)/float(MAX_INTENSITY),
						float(b)/float(MAX_INTENSITY),
						a
						))
				
		print("Palette (256 Colors) loaded from ", filepath, ", size: ", data.size(), ", palettes: ", pal.palettes.size())
	if pal == null:
		printerr("Error loading palette from ", filepath)
	return pal
