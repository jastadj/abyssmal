extends Node

func quit():
	Settings.save_settings()
	get_tree().quit()
	
