extends PanelContainer

const SPRITE_SCALE:float = 16.0

var pal_img:Image = null
var pal_texture:ImageTexture = null

var mapper:PaletteMap = null
var mapper_index:int = 0

var palette:Palette = null:
	get(): return palette
	set(val):
		palette = val
		if is_inside_tree() and palette:
			%OptionButtonPalette.clear()
			for i in range(palette.palettes.size()):
				%OptionButtonPalette.add_item(str(i))
			_update_image()

var palette_index:int = 0:
	get(): return palette_index
	set(val):
		palette_index = val
		if is_inside_tree():
			_update_image()

var light_palmap:PaletteMap = null:
	get(): return light_palmap
	set(val):
		light_palmap = val
		if is_inside_tree() and light_palmap:
			%OptionButtonLightPalMap.clear()
			for i in range(light_palmap.palette_maps.size()):
				%OptionButtonLightPalMap.add_item(str(i))
			_update_image()

var mono_palmap:PaletteMap = null:
	get(): return mono_palmap
	set(val):
		mono_palmap = val
		if is_inside_tree() and mono_palmap:
			%OptionButtonMonoPalMap.clear()
			for i in range(mono_palmap.palette_maps.size()):
				%OptionButtonMonoPalMap.add_item(str(i))
			_update_image()

var light_palmap_index:int = 0:
	get(): return light_palmap_index
	set(val):
		light_palmap_index = val
		if is_inside_tree():
			palette_index = 0
			mapper = light_palmap
			mapper_index = light_palmap_index
			_update_image()

var mono_palmap_index:int = 0:
	get(): return mono_palmap_index
	set(val):
		mono_palmap_index = val
		if is_inside_tree():
			palette_index = 0
			mapper = mono_palmap
			mapper_index = mono_palmap_index
			_update_image()

func _ready():
	# Palette Sprite
	pal_img = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	for y in range(16):
		for x in range(16):
			var r:float = float((y*16) + x) / 255.0
			pal_img.set_pixel(x,y, Color(r, 0, 0))
	pal_texture = ImageTexture.create_from_image(pal_img)
	%Sprite2DPalette.texture = pal_texture
	%Sprite2DPalette.scale = Vector2(1,1) * SPRITE_SCALE
	%Sprite2DPalette.texture_filter = TEXTURE_FILTER_NEAREST
	# Update
	palette = palette
	light_palmap = light_palmap
	mono_palmap = mono_palmap
	palette_index = 0

func _update_image():
	
	%Sprite2DPalette.texture = pal_texture
	%Sprite2DPalette.material.set_shader_parameter("palette_texture", palette.texture)
	%Sprite2DPalette.material.set_shader_parameter("palette_index", palette_index)
	if mapper:
		%Sprite2DPalette.material.set_shader_parameter("mapper_texture", mapper.texture)
		%Sprite2DPalette.material.set_shader_parameter("mapper_index", mapper_index)
		%Sprite2DPalette.material.set_shader_parameter("has_mapper", true)
	else:
		%Sprite2DPalette.material.set_shader_parameter("has_mapper", false)
	

func _on_option_button_palette_item_selected(index: int) -> void:
	mapper = null
	palette_index = index

func _on_option_button_palette_pressed() -> void:
	mapper = null
	palette_index = palette_index

func _on_option_button_light_pal_map_item_selected(index: int) -> void:
	light_palmap_index = index

func _on_option_button_light_pal_map_pressed() -> void:
	light_palmap_index = light_palmap_index

func _on_option_button_mono_pal_map_item_selected(index: int) -> void:
	mono_palmap_index = index

func _on_option_button_mono_pal_map_pressed() -> void:
	mono_palmap_index = mono_palmap_index
