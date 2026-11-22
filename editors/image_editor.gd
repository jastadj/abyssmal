extends PanelContainer

const SPRITE_SCALE:float = 4.0

var palette:Palette = null
var mapper:PaletteMap = null
var mapper_index:int = 0

# key = filename, value = indexed image
var images:Dictionary = {}:
	get(): return images
	set(val):
		images = val

var images_index:int = 0:
	get(): return images_index
	set(val):
		images_index = val
		if is_inside_tree():
			%OptionButtonIndex.clear()
			var key:String = images.keys()[images_index]
			for i in range(images[key].data.size()):
				%OptionButtonIndex.add_item(str(i))
			entry_index = 0

var entry_index:int = 0:
	get(): return entry_index
	set(val):
		entry_index = val
		_update_sprite()

func _ready():
	for key in images.keys():
		%OptionButtonData.add_item(key)
	%Sprite2D.texture_filter = TEXTURE_FILTER_NEAREST
	
	images_index = images_index

func _update_sprite():
	if !palette or images.is_empty():
		return
	var images_key:String = images.keys()[images_index]
	var indexedimage:IndexedImage = images[images_key]
	%Sprite2D.texture = indexedimage.textures[entry_index]
	%Sprite2D.material.set_shader_parameter("palette_texture", palette.texture)
	%Sprite2D.material.set_shader_parameter("palette_index", indexedimage.palette_index)
	if mapper:
		%Sprite2D.material.set_shader_parameter("mapper_texture", mapper.texture)
		%Sprite2D.material.set_shader_parameter("mapper_index", mapper_index)
		%Sprite2D.material.set_shader_parameter("has_mapper", true)
	else:
		%Sprite2D.material.set_shader_parameter("has_mapper", false)

func _on_option_button_data_item_selected(index: int) -> void:
	images_index = index

func _on_option_button_index_item_selected(index: int) -> void:
	entry_index = index

func _on_option_button_data_pressed() -> void:
	images_index = images_index

func _on_option_button_index_pressed() -> void:
	entry_index = entry_index
