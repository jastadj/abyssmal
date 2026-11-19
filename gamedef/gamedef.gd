class_name GameDef
extends Node

enum GameType{NONE, UW1}

var game_name:String = "unnamed"
var game_type:GameType = GameType.NONE
var data_dir:String = ""
var files:Array = []
var palette_file:String = ""
var aux_palette_file:String = ""

# data objects
var palette:Palette = null
var aux_palette:AuxPalette = null

# data loader
var _load_thread:Thread = null
var _load_failed:bool = false

signal load_binary_progress(percent:float, msg:String)
signal load_binaries_done()

static func get_uw1() -> GameDef:
	
	var gd:GameDef = GameDef.new()
	gd.game_name = "Ultima Underworld 1"
	gd.game_type = GameType.UW1
	gd.files.append("DATA/PALS.DAT") # Palette - 256 Colors
	gd.palette_file = gd.files.back()
	gd.files.append("DATA/ALLPALS.DAT") # Aux Palette - 16 Colors
	gd.aux_palette_file = gd.files.back()
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
	var component:String = ""
	var steps:Array = []
	steps.append("Palettes")
	steps.append("Aux Palettes")
	
	_load_failed = false
	
	while !_load_failed:
		_load_component_start(steps[current_step], float(current_step) / float(steps.size()))
		
		# Palettes
		if steps[current_step] == "Palettes":
			if !palette_file.is_empty():
				palette = Palette.load_from_binary(str(data_dir, "/", palette_file))
			if palette == null: _load_component_fail(steps[current_step])
		
		# Aux Palettes
		if steps[current_step] == "Aux Palettes":
			if !aux_palette_file.is_empty():
				aux_palette = AuxPalette.load_from_binary(str(data_dir, "/", aux_palette_file))
			if aux_palette == null: _load_component_fail(steps[current_step])
		
		# done?
		current_step += 1
		
		if current_step >= steps.size():
			break;
	
	# Done
	load_binary_progress.emit( 1.0, "Done.")
	load_binaries_done.emit()
	
