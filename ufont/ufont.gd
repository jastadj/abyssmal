class_name UFont

var font_name:String = ""
var space_width:int = 0
var height:int = 0
var h_separation:int = 1
var max_width:int = 0
var row_bytes:int = 0
var row_bits:int = 0

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

func has_lowercase() -> bool:
	return glyphs.size() >= 127

func create_texture(string:String, color_index:int) -> ImageTexture:
	if !has_lowercase(): string = string.to_upper()
	var w:int = 0
	var line_width:int = 0
	var height_space:int = height + h_separation
	var h:int = height
	# determine size of texture
	for ch in string.to_ascii_buffer():
		if ch >= 0 and ch < glyphs.size():
			if ch == 0x0a:
				h += height_space
				line_width = 0
			else:
				line_width += glyphs[ch].width
			if line_width > w:
				w = line_width
	var img:Image = Image.create(w, h, false, Image.FORMAT_RGBA8)
	# fill with transparent
	img.fill(Color(0, 0, 0))
	# write font character pixels to image
	var x_pos:int = 0
	var y_pos:int = 0
	var color:Color = Color(float(color_index)/255.0, 0, 0)
	for ch in string.to_ascii_buffer():
		if ch >= 0 and ch < glyphs.size():
			if ch == 0x0a:
				y_pos += height_space
				x_pos = 0
			else:
				var g:Glyph = glyphs[ch]
				for row in range(height):
					for bit in range(g.width):
						if g.data[row] & int(pow(2.0, bit)):
							img.set_pixel(x_pos + (g.width - bit), y_pos + row, color)
				x_pos += g.width
	return ImageTexture.create_from_image(img)
