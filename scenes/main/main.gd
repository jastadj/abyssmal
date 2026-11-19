extends Node2D

enum DataEditor{NONE, PALETTES}

var games:Array = []
var cur_game:GameDef = GameDef.new()

func build_game_list():
	%OptionButtonGame.clear()
	games.clear()
	# game list
	games.append(GameDef.get_uw1())
	for game:GameDef in games:
		%OptionButtonGame.add_item(game.game_name, %OptionButtonGame.item_count)
	_on_option_button_game_item_selected(0)

func set_editor(editor:DataEditor):
	for child in %PanelContainerEditor.get_children():
		child.queue_free()
	var new_dlg = null
	match editor:
		DataEditor.PALETTES:
			new_dlg = preload("res://editors/palette_editor.tscn").instantiate()
			new_dlg.palette = cur_game.palette
			new_dlg.aux_palette = cur_game.aux_palette
	if new_dlg:
		%PanelContainerEditor.add_child(new_dlg)

func _ready():
	build_game_list()

func _on_option_button_game_item_selected(index: int) -> void:
	print("Selecting game index ", index)
	%VBoxContainerEditors.visible = false
	%ButtonLoadData.visible = true
	set_editor(DataEditor.NONE)
	cur_game = games[index].duplicate()

func _on_button_load_data_pressed() -> void:
	var dlg = preload("res://ui/common/gamedataloader.tscn").instantiate()
	dlg.connect("data_loaded", func(success:bool):
		%ButtonLoadData.visible = !success
		%VBoxContainerEditors.visible = success
		)
	var selected_idx:int = %OptionButtonGame.selected
	if selected_idx >= 0 and selected_idx < games.size():
		cur_game = games[selected_idx]
		dlg.gamedef = cur_game
	get_tree().current_scene.add_child(dlg)


func _on_button_edit_palettes_pressed() -> void:
	set_editor(DataEditor.PALETTES)
