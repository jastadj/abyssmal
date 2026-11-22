class_name AuxPalette
extends Node

# Aux palettes are mini palettes (16 colors) that reference indices into palette #0

const MAX_COLORS:int = 16

var aux_palettes:Array = []
var texture:ImageTexture = null

static func load_from_binary(filepath:String) -> AuxPalette:
	var auxpal:AuxPalette = null
	print("Loading Aux Palette (16 Colors) from ", filepath)
	var data:PackedByteArray = FileAccess.get_file_as_bytes(filepath)
	if !data.is_empty():
		# calculate the number of aux palettes in this file
		var pal_count:int = data.size() / MAX_COLORS
		# create new aux palette
		auxpal = AuxPalette.new()
		# for each aux palette
		for i in range(pal_count):
			auxpal.aux_palettes.append([])
			# for each palette index
			for n in range(MAX_COLORS):
				auxpal.aux_palettes[i].append(data[(i*MAX_COLORS) + n])
		print("Palette (16 Colors) loaded from ", filepath, ", size: ", data.size(), ", aux palettes: ", auxpal.aux_palettes.size())
	if auxpal == null:
		printerr("Error loading aux palette from ", filepath)
	return auxpal

func generate_texture() -> bool:
	var img:Image = Image.create(MAX_COLORS, aux_palettes.size(), false, Image.FORMAT_RGBA8)
	texture = null
	for y in range(aux_palettes.size()):
		for x in range(MAX_COLORS):
			var r:float = float(aux_palettes[y][x]) / 255.0
			img.set_pixel(x, y, Color(r, 0, 0))
	texture = ImageTexture.create_from_image(img)
	return true
