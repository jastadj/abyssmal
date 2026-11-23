class_name UFont

var font_name:String = ""
var space_width:int = 0
var height:int = 0
var max_width:int = 0
var row_bytes:int = 0

class Glyph:
	var width:int = 0
	var data:Array = []
var glyphs:Array[Glyph] = []

static func load_from_binary(filepath:String) -> UFont:
	print("Loading Font from ", filepath)
	var data:PackedByteArray = FileAccess.get_file_as_bytes(filepath)
	var di:int = 0 # data indexer
	if !data.is_empty():
		var font_width_bytes:int = data.decode_u16(di)
		di += 2
		var char_size_bytes:int = data.decode_u16(di)
		di += 2
		var space_width_px:int = data.decode_u16(di)
		di += 2
		var font_height_px:int = data.decode_u16(di)
		di += 2
		var row_bytes:int = data.decode_u16(di)
		di += 2
		var max_width_px:int = data.decode_u16(di)
		di += 2
		var char_count:int = (data.size() - 12) / (char_size_bytes+1)
		
		var new_font:UFont = UFont.new()
		new_font.space_width = space_width_px
		new_font.height = font_height_px
		new_font.max_width = max_width_px
		new_font.row_bytes = row_bytes
		
		for i in range(char_count):
			var glyph:Glyph = Glyph.new()
			# read in bytes for each font row
			for row in range(0, font_height_px):
				var rowbits = 0
				for b:int in range(row_bytes):
					var db:int = data.decode_u8(di)
					di += 1
					rowbits = rowbits | (db << ( (row_bytes-1-b)*8) )
				glyph.data.append(rowbits)
			glyph.width = data.decode_u8(di)
			di += 1
			# resize font rows
			for k in range(glyph.data.size()):
				glyph.data[k] = glyph.data[k] >> ((row_bytes*8) - glyph.width)
			new_font.glyphs.append(glyph)
		return new_font
	return null

func create_texture(string:String) -> ImageTexture:
	return null
