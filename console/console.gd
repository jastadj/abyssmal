extends CanvasLayer

var logger:ConsoleLogger = ConsoleLogger.new()

func add_output(s:String):
	if !s.ends_with("\n"): s += "\n"
	%output.text += s

func _ready():
	logger.connect("msg_logged", func(msg:String, err:bool):
		add_output(msg)
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
	add_output(new_text)
	%input.clear()


func _on_visibility_changed() -> void:
	if visible:
		%input.grab_focus()
