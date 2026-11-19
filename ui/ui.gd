extends Node

func make_modal(dlg:Control):
	var clayer := CanvasLayer.new()
	clayer.layer = 90
	var blocker := ColorRect.new()
	blocker.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	blocker.color = Color(0.2, 0.2, 0.2, 0.7)
	clayer.add_child(blocker)
	var p = dlg.get_parent()
	if p: p.remove_child(dlg)
	clayer.add_child(dlg)
	clayer.connect("child_exiting_tree", func(child):
		clayer.queue_free()
		)
	dlg.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	get_tree().current_scene.add_child(clayer)
	
