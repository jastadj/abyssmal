extends Node3D

var object = null

func set_object(obj):
	object = obj
	
	if object != null:
		position = Vector3(obj["x"], 0, obj["y"]) * 0.125 * float(System.TILE_SIZE)
		position.y = (float(object["z"]) * 1) / float(System.TILE_SIZE) / 2
		$Sprite3D.texture = System.cur_data["textures"]["objects"][object["id"]]
		$Sprite3D.scale = Vector3(1, 1, 1) * System.TILE_SIZE * 2
		$Sprite3D.offset.y = $Sprite3D.texture.get_height()/2
