extends HBoxContainer

enum FILESELECTOR_MODE{SELECT_FILE, SELECT_DIR}

@export var settings_key:String = ""

@export var mode:FILESELECTOR_MODE = FILESELECTOR_MODE.SELECT_FILE:
	get(): return mode
	set(val):
		mode = val
		if mode == FILESELECTOR_MODE.SELECT_FILE:
			%FileDialog.file_mode = FileDialog.FileMode.FILE_MODE_OPEN_FILE
		elif mode == FILESELECTOR_MODE.SELECT_DIR:
			%FileDialog.file_mode = FileDialog.FileMode.FILE_MODE_OPEN_DIR
			
var filepath:String = "":
	get(): return filepath
	set(val):
		filepath = val
		%LineEdit.text = filepath
		if !settings_key.is_empty():
			Settings.write(settings_key, filepath)
		%FileDialog.current_path = filepath

func _ready():
	if !settings_key.is_empty():
		if Settings.has(settings_key):
			filepath = Settings.read(settings_key)
	mode = mode
	

func _on_button_select_path_pressed() -> void:
	%FileDialog.show()


func _on_file_dialog_dir_selected(dir: String) -> void:
	filepath = dir + "/"

func _on_file_dialog_file_selected(path: String) -> void:
	filepath = path

func _on_line_edit_text_submitted(new_text: String) -> void:
	filepath = new_text
