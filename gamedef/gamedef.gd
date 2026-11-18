class_name GameDef
extends Node

var game_name:String = "unnamed"
var data_dir:String = ""
var files:Array = []
var palette_file:String = ""
var palette:Palette = null

var _load_thread:Thread = null

signal load_binary_progress(percent:float, msg:String)

static func get_uw1() -> GameDef:
	
	var gd:GameDef = GameDef.new()
	gd.game_name = "Ultima Underworld 1"
	if Settings.has("uw1_dir"):
		gd.data_dir = Settings.read("uw1_dir")
	
	# Palette - 256 Colors
	gd.files.append(str(gd.data_dir, "/", "DATA/PALS.DAT"))
	gd.palette_file = gd.files.back()
	return gd
	
func load_from_binaries():
	if !_load_thread:
		_load_thread = Thread.new()
		_load_thread.start(_load_from_binaries_thread)

			
func _load_from_binaries_thread():
	var total_steps:int = 1
	var current_step:int = 0
	load_binary_progress.emit( current_step / total_steps, "Loading...")
	
	# 1
	if !palette_file.is_empty():
		load_binary_progress.emit( current_step / total_steps, "Loading Palettes...")
		palette = Palette.load_from_binary(palette_file)
	current_step += 1
	
	# Done
	load_binary_progress.emit( current_step / total_steps, "Done.")
	
