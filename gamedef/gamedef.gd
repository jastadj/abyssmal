class_name GameDef
extends Node

enum GameType{NONE, UW1}

var game_name:String = "unnamed"
var game_type:GameType = GameType.NONE
var data_dir:String = ""

# palette files
var palette_file := String()
var aux_palette_file := String()
var light_palette_map_file := String()
var mono_palette_map_file := String()

# palettes
var palette:Palette = null
var aux_palette:AuxPalette = null
var light_palette_map:PaletteMap = null
var mono_palette_map:PaletteMap = null

# bitmap images
var bitmap_files:PackedStringArray
var bitmaps:Array[ImageArchive] = []

# graphics
var graphic_files:PackedStringArray
var graphics:Array[ImageArchive] = []

# textures
var texture_files:PackedStringArray
var textures:Array[ImageArchive] = []

# data loader
var _load_thread:Thread = null
var _load_failed:bool = false

signal load_binary_progress(percent:float, msg:String)
signal load_binaries_done()

static func get_uw1() -> GameDef:
	
	var gd:GameDef = GameDef.new()
	gd.game_name = "Ultima Underworld 1"
	gd.game_type = GameType.UW1
	# palettes
	gd.palette_file = "DATA/PALS.DAT"
	gd.aux_palette_file = "DATA/ALLPALS.DAT"
	gd.light_palette_map_file = "DATA/LIGHT.DAT"
	gd.mono_palette_map_file = "DATA/MONO.DAT"
	# bitmaps
	gd.bitmap_files = [
		"DATA/BLNKMAP.BYT",
		"DATA/CHARGEN.BYT",
		"DATA/CONV.BYT",
		"DATA/MAIN.BYT",
		"DATA/OPSCR.BYT",
		"DATA/PRES1.BYT",
		"DATA/PRES2.BYT",
		"DATA/WIN1.BYT",
		"DATA/WIN2.BYT"
	]
	# graphics
	gd.graphic_files = [
		"DATA/3DWIN.GR",
		"DATA/ANIMO.GR",
		"DATA/ARMOR_F.GR",
		"DATA/ARMOR_M.GR",
		"DATA/BODIES.GR",
		"DATA/BUTTONS.GR",
		"DATA/CHAINS.GR",
		"DATA/CHARHEAD.GR",
		"DATA/CHRBTNS.GR",
		"DATA/COMPASS.GR",
		"DATA/CONVERSE.GR",
		"DATA/CURSORS.GR",
		"DATA/DOORS.GR",
		"DATA/DRAGONS.GR",
		"DATA/EYES.GR",
		"DATA/FLASKS.GR",
		"DATA/GENHEAD.GR",
		"DATA/HEADS.GR",
		"DATA/INV.GR",
		"DATA/LFTI.GR",
		"DATA/OBJECTS.GR",
		"DATA/OPBTN.GR"
	]
	# textures
	gd.texture_files = [
		"DATA/F16.TR",
		"DATA/F32.TR",
		"DATA/W16.TR",
		"DATA/W64.TR",
	]
	
	return gd

func is_loading() -> bool:
	return _load_thread != null and _load_thread.is_alive()
	
func load_failed() -> bool:
	return _load_failed

func load_binaries():
	if _load_thread:
		_load_thread.wait_to_finish()
	_load_thread = Thread.new()
	_load_thread.start(_load_binaries_thread)

func _load_component_start(component:String, progress:float):
	print("Loading binary for ", component, "...")
	load_binary_progress.emit(progress, str("Loading ", component, "..."))

func _load_component_fail(component:String):
	_load_failed = true
	printerr(component, " failed to load.")

func _load_binaries_thread():
	var current_step:int = 0
	var steps:Array = []
	steps.append(palette_file)
	steps.append(aux_palette_file)
	steps.append(light_palette_map_file)
	steps.append(mono_palette_map_file)
	for bitmap_file in bitmap_files:
		steps.append(bitmap_file)
	for graphics_file in graphic_files:
		steps.append(graphics_file)
	for texture_file in texture_files:
		steps.append(texture_file)
	
	_load_failed = false
	
	while !_load_failed:
		_load_component_start(steps[current_step], float(current_step) / float(steps.size()))
		
		# Palettes
		if steps[current_step] == palette_file:
			palette = Palette.load_from_binary(str(data_dir, "/", palette_file))
			if palette == null: _load_component_fail(steps[current_step])
			else:
				if !palette.generate_texture(): _load_component_fail(steps[current_step])
				else:
					print("Generated texture for ", steps[current_step])
		
		# Aux Palettes
		elif steps[current_step] == aux_palette_file:
			aux_palette = AuxPalette.load_from_binary(str(data_dir, "/", aux_palette_file))
			if aux_palette == null: _load_component_fail(steps[current_step])
			else:
				if !aux_palette.generate_texture(): _load_component_fail(steps[current_step])
				else:
					print("Generated texture for ", steps[current_step])
			
		# Light Palette Map
		elif steps[current_step] == light_palette_map_file:
			light_palette_map = PaletteMap.load_from_binary(str(data_dir, "/", light_palette_map_file))
			if light_palette_map == null: _load_component_fail(steps[current_step])
			else:
				if !light_palette_map.generate_texture(palette): _load_component_fail(steps[current_step])
				else:
					print("Generated texture for ", steps[current_step])
		
		# Mono Palette Map
		elif steps[current_step] == mono_palette_map_file:
			mono_palette_map = PaletteMap.load_from_binary(str(data_dir, "/", mono_palette_map_file))
			if mono_palette_map == null: _load_component_fail(steps[current_step])
			else:
				if !mono_palette_map.generate_texture(palette): _load_component_fail(steps[current_step])
				else:
					print("Generated texture for ", steps[current_step])
		
		# Bitmap Files
		elif bitmap_files.has(steps[current_step]):
			var imgarchive:ImageArchive = ImageArchive.load_bitmap_file(str(data_dir, "/", steps[current_step]))
			if imgarchive == null: _load_component_fail(steps[current_step])
			else:
				imgarchive.archive_name = steps[current_step]
				bitmaps.append(imgarchive)
				if game_type == GameType.UW1:
					var p:int = 0
					match steps[current_step]:
						"DATA/BLNKMAP.BYT": p = 1
						"DATA/CHARGEN.BYT": p = 3
						"DATA/OPSCR.BYT": p = 2
						"DATA/PRES1.BYT": p = 5
						"DATA/PRES2.BYT": p = 5
						"DATA/WIN1.BYT": p = 7
						"DATA/WIN2.BYT": p = 7
						_: p = 0
					for img in imgarchive.images:
						if img: img.palette_index = p
		
		# Graphics Files
		elif graphic_files.has(steps[current_step]):
			var imgarchive:ImageArchive = ImageArchive.load_graphics_file(str(data_dir, "/", steps[current_step]))
			if imgarchive == null: _load_component_fail(steps[current_step])
			else:
				imgarchive.archive_name = steps[current_step]
				graphics.append(imgarchive)
		
		# Texture Files
		elif texture_files.has(steps[current_step]):
			var imgarchive:ImageArchive = ImageArchive.load_graphics_file(str(data_dir, "/", steps[current_step]))
			if imgarchive == null: _load_component_fail(steps[current_step])
			else:
				imgarchive.archive_name = steps[current_step]
				textures.append(imgarchive)
		
		# ERROR
		else:
			printerr("Load binaries error, unhandled step: ", steps[current_step])
		
		# done?
		current_step += 1
		
		if current_step >= steps.size():
			break;
	
	# Done
	load_binary_progress.emit( 1.0, "Done.")
	load_binaries_done.emit()
	
