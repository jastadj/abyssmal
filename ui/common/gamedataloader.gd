extends PanelContainer

var gamedef:GameDef = null:
	get(): return gamedef
	set(val):
		gamedef = val
		%Label.text = gamedef.game_name
		%pathselector.settings_key = gamedef.game_name

signal data_loaded(result:bool)

func _ready():
	UI.make_modal(self)

func _on_button_start_load_pressed() -> void:
	if !gamedef.is_loading():
		%ButtonClose.disabled = true
		if !gamedef.has_connections("load_binary_progress"):
			gamedef.connect("load_binary_progress", _on_load_binary_progress_update, CONNECT_DEFERRED)
		if !gamedef.has_connections("load_binaries_done"):
			gamedef.connect("load_binaries_done", _on_load_binaries_done, CONNECT_DEFERRED)
		gamedef.data_dir = %pathselector.filepath
		gamedef.load_binaries()

func _on_load_binary_progress_update(percent:float, msg:String):
		%load_progress.progress = percent
		%load_progress.text = msg

func _on_load_binaries_done():
	%ButtonClose.disabled = false
	if gamedef.load_failed():
		%load_progress.color = Color.RED
	else:
		%load_progress.color = Color.GREEN
	data_loaded.emit(!gamedef.load_failed())

func _on_button_close_pressed() -> void:
	queue_free()
