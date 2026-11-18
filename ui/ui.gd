extends Node

func make_modal(dlg:Control):
	var clayer := CanvasLayer.new()
	clayer.layer = 90
	var blocker := Control.new()
	blocker.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	clayer.add_child(blocker)
	var p = dlg.get_parent()
	if p: p.remove_child(dlg)
	clayer.add_child(dlg)
	dlg.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	get_tree().current_scene.add_child(clayer)
	
