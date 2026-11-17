extends Node2D

func _ready():
	
	if Settings.has("uw1_dir"):
		%pathselector.filepath = Settings.read("uw1_dir")
