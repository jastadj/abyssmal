extends MarginContainer

@export var progress:float = 0.0:
	get(): return progress
	set(val):
		progress = clamp(val, 0, 1.0)
		%ProgressBar.value = progress * 100.0

@export var text:String = "":
	get(): return text
	set(val):
		text = val
		%Label.text = text

func _ready():
	progress = progress
	text = text
