extends Camera2D

@export var zoom_step: float = 0.1
@export var min_zoom: float = 0.2
@export var max_zoom: float = 4.0

var invert_zoom:bool = true
var dragging := false

func _unhandled_input(event: InputEvent) -> void:
	# RMB drag start/end
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			dragging = event.pressed

		# Zoom in
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			if invert_zoom: _zoom_at_mouse(1.0 + zoom_step)
			else: _zoom_at_mouse(1.0 - zoom_step)

		# Zoom out
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			if invert_zoom: _zoom_at_mouse(1.0 - zoom_step)
			else: _zoom_at_mouse(1.0 + zoom_step)

	# Pan while RMB held
	elif event is InputEventMouseMotion and dragging:
		position -= event.relative / zoom


func _zoom_at_mouse(factor: float) -> void:
	var mouse_screen := get_viewport().get_mouse_position()

	# World position under cursor before zoom
	var world_before := get_global_mouse_position()

	# Apply zoom
	var new_zoom := zoom * factor
	new_zoom.x = clampf(new_zoom.x, min_zoom, max_zoom)
	new_zoom.y = clampf(new_zoom.y, min_zoom, max_zoom)
	zoom = new_zoom

	# World position under cursor after zoom
	var world_after := get_global_mouse_position()

	# Move camera so cursor stays over same world point
	position += world_before - world_after
