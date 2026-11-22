extends PanelContainer

const SPRITE_SCALE:float = 2.0

var palette:Palette = null
var mapper:PaletteMap = null
var auxpalette:AuxPalette = null
var mapper_index:int = 0

# key = filename, value = indexed image
var images:Array[ImageArchive] = []:
	get(): return images
	set(val):
		images = val
		if is_inside_tree():
			%OptionButtonData.clear()
			for imgarchive:ImageArchive in images:
				%OptionButtonData.add_item(imgarchive.archive_name)
			images_index = 0
			entry_index = 0

var images_index:int = 0:
	get(): return images_index
	set(val):
		images_index = val
		if is_inside_tree():
			%OptionButtonIndex.clear()
			var imgarchive:ImageArchive = images[images_index]
			for i in range(imgarchive.images.size()):
				%OptionButtonIndex.add_item(str(i))
				entry_index = 0

var entry_index:int = 0:
	get(): return entry_index
	set(val):
		entry_index = val
		if is_inside_tree():
			var imgarchive:ImageArchive = images[images_index]
			entry_index = clamp(entry_index, 0, imgarchive.images.size()-1)
			var indexedimage:IndexedImage = imgarchive.images[entry_index]
			if indexedimage != null:
				%OptionButtonIndex.select(entry_index)
				palette_index = indexedimage.palette_index
				auxpalette_index = indexedimage.aux_palette
			_update_sprite()
		else: entry_index = 0

var palette_index:int = 0:
	get(): return palette_index
	set(val):
		palette_index = val
		%OptionButtonPalette.select(palette_index)
		_update_sprite()

var auxpalette_index:int = -1:
	get(): return auxpalette_index
	set(val):
		auxpalette_index = val
		%HBoxContainerAuxPalette.visible = auxpalette_index >= 0
		if auxpalette_index >= 0:
			%OptionButtonAuxPalette.select(auxpalette_index)
		_update_sprite()

func _ready():
	_update_palette_index()
	_update_auxpalette_index()
	%Sprite2D.texture_filter = TEXTURE_FILTER_NEAREST
	%Sprite2D.scale = Vector2(1,1) * SPRITE_SCALE
	images = images

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_LEFT:
				entry_index -= 1
			elif event.keycode == KEY_RIGHT:
				entry_index += 1
			grab_focus()
			release_focus()
		get_viewport().set_input_as_handled()
			

func _update_palette_index():
	if is_inside_tree():
		%OptionButtonPalette.clear()
		if palette:
			for i in range(palette.palettes.size()):
				%OptionButtonPalette.add_item(str(i))

func _update_auxpalette_index():
	if is_inside_tree():
		%OptionButtonAuxPalette.clear()
		if auxpalette:
			for i in range(auxpalette.aux_palettes.size()):
				%OptionButtonAuxPalette.add_item(str(i))

func _update_sprite():
	if !is_inside_tree() or !palette or images.is_empty():
		return
	var imgarchive:ImageArchive = images[images_index]
	var indexedimage:IndexedImage = imgarchive.images[entry_index]
	var texture:ImageTexture = null
	if indexedimage: texture = indexedimage.texture
	%Sprite2D.texture = texture
	%Sprite2D.material.set_shader_parameter("palette_texture", palette.texture)
	%Sprite2D.material.set_shader_parameter("palette_index", palette_index)
	if mapper:
		%Sprite2D.material.set_shader_parameter("mapper_texture", mapper.texture)
		%Sprite2D.material.set_shader_parameter("mapper_index", mapper_index)
		%Sprite2D.material.set_shader_parameter("has_mapper", true)
	else:
		%Sprite2D.material.set_shader_parameter("has_mapper", false)
	if auxpalette_index >= 0:
		%Sprite2D.material.set_shader_parameter("aux_palette_texture", auxpalette.texture)
		%Sprite2D.material.set_shader_parameter("aux_palette", auxpalette_index)
		%Sprite2D.material.set_shader_parameter("has_aux_palette", true)
	else:
		%Sprite2D.material.set_shader_parameter("has_aux_palette", false)

func _on_option_button_data_item_selected(index: int) -> void:
	images_index = index

func _on_option_button_index_item_selected(index: int) -> void:
	entry_index = index

func _on_option_button_palette_item_selected(index: int) -> void:
	palette_index = index

func _on_option_button_aux_palette_item_selected(index: int) -> void:
	auxpalette_index = index

func _on_option_button_data_pressed() -> void:
	images_index = images_index

func _on_option_button_index_pressed() -> void:
	entry_index = entry_index

func _on_option_button_palette_pressed() -> void:
	palette_index = palette_index

func _on_option_button_aux_palette_pressed() -> void:
	auxpalette_index = auxpalette_index
	


func _on_button_left_pressed() -> void:
	entry_index = entry_index - 1


func _on_button_right_pressed() -> void:
	entry_index = entry_index + 1
