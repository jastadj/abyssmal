extends Node

const settings_file:String = "user://settings.json"
const settings_version:String = "0.1"

var data:Dictionary = {}

func new_settings():
	data = _get_new_settings()

func save_settings() -> bool:
	var result:bool = false
	var fa:FileAccess = FileAccess.open(settings_file, FileAccess.WRITE)
	if fa.is_open():
		var s:String = JSON.stringify(data, "  ")
		if !s.is_empty():
			result = fa.store_string(s)
		fa.close()
	if result: print("Saved settings to: ", settings_file)
	else: printerr("Unable to save settings to: ", settings_file)
	return result

func load_settings() -> bool:
	var result:bool = false
	if FileAccess.file_exists(settings_file):
		var s:String = FileAccess.get_file_as_string(settings_file)
		var d = JSON.parse_string(s)
		if d and d is Dictionary:
			var new_settings:Dictionary = _get_new_settings()
			data = new_settings.merged(d, true)
			result = data.has("version")
	if result:
		print("Loaded settings from: ", settings_file, ", version: ", data["version"])
	else: printerr("Unable to load settings from: ", settings_file)
	return result

func _ready():
	new_settings()
	if !FileAccess.file_exists(settings_file):
		save_settings()
	else:
		load_settings()

func _get_new_settings() -> Dictionary:
	var d:Dictionary = {}
	d["version"] = settings_version
	return d
