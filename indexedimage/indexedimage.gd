class_name IndexedImage
extends Node

var palette_index:int = 0
var data:Array = [] # array of arrays (palette indices that make up image)
var textures:Array = [] # array of textures that store the indices in the r component

static func load_from_binary(filepath:String) -> Array:
	return []

static func load_bitmap_file(filepath:String) -> IndexedImage:
	const dims := Vector2i(320,200)
	print("Loading Bitmap Image from ", filepath)
	var data:PackedByteArray = FileAccess.get_file_as_bytes(filepath)
	if !data.is_empty() and data.size() >= (dims.x * dims.y):
		var idata:Array = []
		var iimage:IndexedImage = IndexedImage.new()
		for i in range(dims.x * dims.y):
			idata.append(data[i])
		var texture:ImageTexture = _generate_texture(idata, dims)
		if texture:
			iimage.data.append(idata)
			iimage.textures.append(texture)
			return iimage
	return null

static func load_image_file(filename:String, palette:int):
	var image_entries = []
	var tfile = FileAccess.open(filename, FileAccess.READ)
	
	if(tfile == null):
		print("Error opening image file:" + filename)
		return false
	
	# IMAGE FILE HEADER
	var format = tfile.get_8()
	var fixed_size = null
	match format:
		1:
			pass
		2:
			fixed_size = tfile.get_8()
		_:
			print("Unrecognized image file format:", format)
			return false
	var image_count = tfile.get_16()
	var offsets = []
	# get offsets
	for i in range(0, image_count):
		offsets.append(tfile.get_32())
	
	# get image at offsets
	for i in range(0, offsets.size()):
		
		# if null record, add null entry
		if (i > 0):
			if (offsets[i] == offsets[i-1]) or (offsets[i] >= tfile.get_length()):
				image_entries.append(null)
				continue
		
		# seek to offset
		tfile.seek(offsets[i])
		
		# IMAGE HEADER
		var image_entry
		var image_type = System.IMAGE_FORMAT.FMT_8BIT
		if (format == 1): image_type = tfile.get_8()
		var width
		var height
		if(fixed_size):
			width = fixed_size
			height = fixed_size
		else:
			width = tfile.get_8()
			height = tfile.get_8()
		var aux_pal = -1
		var pixel_data = []
		if (image_type == System.IMAGE_FORMAT.FMT_4BIT or
		image_type == System.IMAGE_FORMAT.FMT_4BIT_RLE ):
			aux_pal = tfile.get_8()
		var data_size
		if(format == 2): data_size = height*width
		else: data_size = tfile.get_16()
		pixel_data.resize(width*height)
		
		# create image entry
		image_entry = System.new_image(image_type, palette, aux_pal)
		image_entry["width"] = width
		image_entry["height"] = height
		
		# if 8 bit uncompressed
		if (image_type == System.IMAGE_FORMAT.FMT_8BIT):
			for n in range(0, data_size):
				pixel_data[n] = tfile.get_8()
		#  if 4 bit uncompressed
		elif (image_type == System.IMAGE_FORMAT.FMT_4BIT):
			for n in range(0, data_size):
				var byte = tfile.get_8()
				pixel_data[(n*2)] = byte & 0xf0 >> 4
				if( (n*2) + 1 >= width*height): continue
				pixel_data[(n*2)+1] = byte & 0xf
		elif (image_type == System.IMAGE_FORMAT.FMT_4BIT_RLE or 
		image_type == System.IMAGE_FORMAT.FMT_5BIT_RLE):
			var word_size = 4
			if(image_type == System.IMAGE_FORMAT.FMT_5BIT_RLE): word_size = 5
			if(word_size == 4):	data_size = ceil( float(data_size) / 2.0)
			else: data_size = ceil( float(data_size*5)/8.0)
			# create bitstream
			var bit_stream = []
			for b in range(0, data_size):
				var byte = tfile.get_8()
				for n in range(0, 8):
					bit_stream.append( (byte & (0x1 << 7-n)) >> (7-n) )
			pixel_data = decode_rle_bitstream(word_size, bit_stream)
			if(pixel_data.size() > width*height): pixel_data.resize(width*height)
		else:
			printerr("Error loading graphics file ", filename, " at offset ", offsets[i], " : unrecognized image type ", image_type)
			return false
		
		# done
		image_entry["data"] = pixel_data
		image_entries.append(image_entry)
			
	return image_entries

static func decode_rle_bitstream(word_size:int, bits:Array):
	var repeat_mode = true
	var atom_map = []
	
	# decode bits
	while (bits.size() >= word_size):
		
		# get a count
		var count = rle_get_count(bits, word_size)
		
		# repeat mode
		if (repeat_mode):
			# if count == 1, skip this record and do a run
			if (count == 1):
				repeat_mode = false
				continue
			# if count == 2, perform multiple repeats
			elif (count == 2):
				var repeats = rle_get_count(bits, word_size)
				while repeats > 0:
					count = rle_get_count(bits, word_size)
					var value = rle_extract_word(bits, word_size)
					while count > 0:
						atom_map.append(value)
						count -= 1
					repeats -= 1
			else:
				var val = rle_extract_word(bits, word_size)
				for n in range(0, count):
					atom_map.append(val)
		# run mode
		else:
			for i in range(0, count):
				atom_map.append(rle_extract_word(bits, word_size))
		repeat_mode = !repeat_mode
	
	return atom_map;

static func rle_get_count(bits:Array, wordsize):
	var count = rle_extract_word(bits, wordsize)
	# if count == 0, get two more words
	if (!count):
		var count1 = rle_extract_word(bits, wordsize)
		var count2 = rle_extract_word(bits, wordsize)
		count = count1 << 4 | count2 # note: when shifting, shift by 4 bits regardless of wordcount
		# if count is still == 0, get three more words
		if(!count):
			var count3 = rle_extract_word(bits,wordsize)
			var count4 = rle_extract_word(bits,wordsize)
			var count5 = rle_extract_word(bits,wordsize)
			count = (count3 << 8) | (count4 << 4) | count5
	return count

static func rle_extract_word(bits:Array, word_size:int):
	var val = 0
	if(bits.size() == 0 or bits.size() < word_size): return val
	for i in range(0, word_size):
		val = (val << 1) | bits[0]
		bits.pop_front()
	return val

static func _generate_texture(idata:Array, dims:Vector2i) -> ImageTexture:
	var img:Image = Image.create(dims.x, dims.y, false, Image.FORMAT_RGBA8)
	for y in range(dims.y):
		for x in range(dims.x):
			var r:float = float(idata[(y*dims.x) + x]) / 255.0
			img.set_pixel(x, y, Color(r, 0, 0, 1))
	var texture:ImageTexture = ImageTexture.create_from_image(img)
	return texture
