extends CanvasLayer

var logger:ConsoleLogger = ConsoleLogger.new()

func add_output(s:String, is_error:bool = false):
	if Thread.is_main_thread():
		if is_error:
			s = str("[ERROR] ", s)
		if !s.ends_with("\n"): s += "\n"
		%output.text += s
	else:
		call_deferred("add_output", s, is_error)

func _ready():
	logger.connect("msg_logged", func(msg:String, err:bool):
		add_output(msg, err)
		)
	OS.add_logger(logger)
	hide()
	%output.clear()
	%input.connect("text_submitted", _on_text_submitted)

func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_QUOTELEFT and !event.pressed:
			visible = !visible
	
func _on_text_submitted(new_text:String):
	add_output(str("> ", new_text))
	%commands.execute(new_text)
	%input.clear()


func _on_visibility_changed() -> void:
	if visible:
		%input.grab_focus()


func _on_input_text_changed(new_text: String) -> void:
	if %input.text.contains("`"):
		%input.text = %input.text.replace("`", "")
