extends Node2D

var games:Array = []
var cur_game:GameDef = null

func build_game_list():
	%OptionButtonGame.clear()
	games.clear()
	# game list
	games.append(GameDef.get_uw1())
	for game:GameDef in games:
		%OptionButtonGame.add_item(game.game_name, %OptionButtonGame.item_count)

func _ready():
	build_game_list()

func _on_option_button_game_item_selected(index: int) -> void:
	print("Selecting game index ", index)
	var gamedef:GameDef = games[index]
	cur_game = gamedef.duplicate()


func _on_button_load_data_pressed() -> void:
	var dlg = preload("res://ui/common/gamedataloader.tscn").instantiate()
	# TODO set current game to selected game, set this game for the gamedataloader
	get_tree().current_scene.add_child(dlg)
