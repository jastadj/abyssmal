extends Node

const settings_file:String = "user://settings.json"
const settings_version:String = "0.1"

var _data:Dictionary = {}

func has(setting:String) -> bool:
	if !setting.is_empty():
		return _data.has(setting)
	return false
	
func write(setting:String, val):
	_data[setting] = val

func read(setting:String):
	if has(setting):
		return _data[setting]
	return null

func new_settings():
	_data = _get_new_settings()

func save_settings() -> bool:
	var result:bool = false
	var fa:FileAccess = FileAccess.open(settings_file, FileAccess.WRITE)
	if fa.is_open():
		var s:String = JSON.stringify(_data, "  ")
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
			var new_settings_dict:Dictionary = _get_new_settings()
			_data = new_settings_dict.merged(d, true)
			result = _data.has("version")
	if result:
		print("Loaded settings from: ", settings_file, ", version: ", _data["version"])
	else: printerr("Unable to load settings from: ", settings_file)
	return result

func _ready():
	new_settings()
	if !FileAccess.file_exists(settings_file):
		save_settings()
	load_settings()
		
func _exit_tree() -> void:
	await save_settings()
	

func _get_new_settings() -> Dictionary:
	var d:Dictionary = {}
	d["version"] = settings_version
	return d
