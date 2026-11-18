extends Node2D

func _ready():
	
	if Settings.has("uw1_dir"):
		%pathselector.filepath = Settings.read("uw1_dir")
	
	%load_progress.progress = 0.0
	%load_progress.text = "test"


func _on_button_start_load_pressed() -> void:
	# UW1 game
	var uw1:GameDef = GameDef.get_uw1()
	uw1.connect("load_binary_progress", _on_load_progress, CONNECT_DEFERRED)
	uw1.load_from_binaries()

func _on_load_progress(percent:float, msg:String):
	%load_progress.progress = percent
	%load_progress.text = msg
