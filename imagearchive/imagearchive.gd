class_name ImageArchive
extends Node

enum FILE_FORMAT{INVALID, GR, TR, CR, SR, AR}

var archive_name:String = ""
var images:Array = [] # indeximages from archive

static func load_bitmap_file(filepath:String) -> ImageArchive:
	const dims := Vector2i(320,200)
	print("Loading Bitmap Image from ", filepath)
	var data:PackedByteArray = FileAccess.get_file_as_bytes(filepath)
	if !data.is_empty() and data.size() >= (dims.x * dims.y):
		var idata:Array = []
		for i in range(dims.x * dims.y):
			idata.append(data[i])
		var iimage:IndexedImage = IndexedImage.new()
		iimage.format = IndexedImage.IMAGE_FORMAT.FMT_8BIT
		iimage.data = idata
		iimage.dims = dims
		var texture:ImageTexture = iimage.generate_texture()
		if texture:
			var imgarchive:ImageArchive = ImageArchive.new()
			imgarchive.images.append(iimage)
			return imgarchive
	return null

static func load_graphics_file(filepath:String) -> ImageArchive:
	print("Loading Graphics from ", filepath)
	var data:PackedByteArray = FileAccess.get_file_as_bytes(filepath)
	if !data.is_empty():
		var imgarchive:ImageArchive = ImageArchive.new()
		var di:int = 0 # data index
		# HEADER
		var texture_size:int = 0
		var fileformat:FILE_FORMAT = data.decode_u8(di)
		di += 1
		match fileformat:
			FILE_FORMAT.GR:
				pass
			FILE_FORMAT.TR:
				texture_size = data[di]
				di += 1
			_:
				printerr("Unrecognized image file format:", fileformat)
				return null
		var image_count:int = data.decode_u16(di)
		di += 2
		
		# get image data offsets
		var offsets:Array = []
		for i in range(0, image_count):
			offsets.append(data.decode_u32(di))
			di += 4
		
		# get image at offsets
		for i in range(0, offsets.size()):
			
			# if null record, add null entry
			if (i > 0):
				if (offsets[i] == offsets[i-1]) or (offsets[i] >= data.size()):
					imgarchive.images.append(null)
					continue
			
			# IMAGE HEADER
			var ioff:int = offsets[i]
			var image_type:IndexedImage.IMAGE_FORMAT = IndexedImage.IMAGE_FORMAT.FMT_8BIT
			var dims:=Vector2i()
			var pixel_count:int = 0
			if fileformat == FILE_FORMAT.GR:
				image_type = data.decode_u8(ioff)
				dims = Vector2i(data[ioff+1], data[ioff+2])
				ioff += 3
			elif fileformat == FILE_FORMAT.TR:
				dims = Vector2i(texture_size, texture_size)
			var aux_pal:int = -1
			var pixel_data:Array = []
			pixel_count = dims.x * dims.y
			if (image_type == IndexedImage.IMAGE_FORMAT.FMT_4BIT or
			image_type == IndexedImage.IMAGE_FORMAT.FMT_4BIT_RLE ):
				aux_pal = data[ioff]
				ioff += 1
			# data size
			var data_size:int = 0
			if fileformat == FILE_FORMAT.TR: data_size = pixel_count
			else:
				data_size = data.decode_u16(ioff)
				ioff += 2
			pixel_data.resize(pixel_count)
			pixel_data.fill(0)
			
			# if 8 bit uncompressed
			if (image_type == IndexedImage.IMAGE_FORMAT.FMT_8BIT):
				for n in range(0, data_size):
					pixel_data[n] = data.decode_u8(ioff)
					ioff += 1
			#  if 4 bit uncompressed
			elif (image_type == IndexedImage.IMAGE_FORMAT.FMT_4BIT):
				for n in range(0, data_size):
					var byte:int = data.decode_u8(ioff)
					ioff += 1
					pixel_data[(n*2)] = byte & 0xf0 >> 4
					if( (n*2) + 1 >= pixel_count): continue
					pixel_data[(n*2)+1] = byte & 0xf
			# run length encoded
			elif (image_type == IndexedImage.IMAGE_FORMAT.FMT_4BIT_RLE or 
			image_type == IndexedImage.IMAGE_FORMAT.FMT_5BIT_RLE):
				var word_size:int = 4
				if image_type == IndexedImage.IMAGE_FORMAT.FMT_5BIT_RLE: word_size = 5
				if word_size == 4:
					data_size = ceil( float(data_size) / 2.0)
				else:
					data_size = ceil( float(data_size*5)/8.0)
				# create bitstream
				var bit_stream = []
				for b in range(0, data_size):
					var byte:int = data.decode_u8(ioff)
					ioff += 1
					for n in range(0, 8):
						bit_stream.append( (byte & (0x1 << 7-n)) >> (7-n) )
				pixel_data = decode_rle_bitstream(word_size, bit_stream)
				if pixel_data.size() > pixel_count:
					pixel_data.resize(pixel_count)
			else:
				printerr("Error loading graphics file ", filepath, " at offset ", offsets[i], " : unrecognized image type ", image_type)
				return null
			
			# done with graphic
			var indexedimage:IndexedImage = IndexedImage.new()
			indexedimage.dims = dims
			indexedimage.aux_palette = aux_pal
			indexedimage.data = pixel_data
			indexedimage.format = image_type
			var texture:ImageTexture = indexedimage.generate_texture()
			if texture:
				imgarchive.images.append(indexedimage)
			else:
				printerr("Error generating image data from ", filepath, " at offset ", offsets[i])
				return null
		# done with file
		return imgarchive
	return null

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
