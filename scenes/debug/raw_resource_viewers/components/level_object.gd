extends Node2D

var object = null

func set_object(tgt_object, object_textures):
	
	object = tgt_object
	
	if object:
		var bg_size = $bg_sprite.get_rect()
		var img = object_textures[object["id"]]
		var img_scale = Vector2(bg_size.size.x / img.get_width(), bg_size.size.y / img.get_height())
		$fg_sprite.texture = ImageTexture.create_from_image(img)
		$fg_sprite.scale = img_scale * 2
	
	
