extends HBoxContainer

enum FILESELECTOR_MODE{SELECT_FILE, SELECT_DIR}

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

func _ready():
	mode = mode
	

func _on_button_select_path_pressed() -> void:
	%FileDialog.show()


func _on_file_dialog_dir_selected(dir: String) -> void:
	filepath = dir

func _on_file_dialog_file_selected(path: String) -> void:
	filepath = path
