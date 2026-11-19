extends PanelContainer

const SPRITE_SCALE:float = 16.0

var current_data = null

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
			current_data = palette
			_update_image()

var aux_palette:AuxPalette = null:
	get(): return aux_palette
	set(val):
		aux_palette = val
		if is_inside_tree() and aux_palette:
			%OptionButtonAuxPalette.clear()
			for i in range(aux_palette.aux_palettes.size()):
				%OptionButtonAuxPalette.add_item(str(i))
			_update_image()

var aux_palette_index:int = 0:
	get(): return aux_palette_index
	set(val):
		aux_palette_index = val
		if is_inside_tree():
			current_data = aux_palette
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

var light_palmap_index:int = 0:
	get(): return light_palmap_index
	set(val):
		light_palmap_index = val
		if is_inside_tree():
			current_data = light_palmap
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

var mono_palmap_index:int = 0:
	get(): return mono_palmap_index
	set(val):
		mono_palmap_index = val
		if is_inside_tree():
			current_data = mono_palmap
			_update_image()

# Resources
var pal_img:Image = null
var pal_texture:ImageTexture = null

func _ready():
	# Palette Sprite
	pal_img = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	pal_texture = ImageTexture.create_from_image(pal_img)
	%Sprite2DPalette.texture = pal_texture
	%Sprite2DPalette.scale = Vector2(SPRITE_SCALE, SPRITE_SCALE)
	%Sprite2DPalette.texture_filter = TEXTURE_FILTER_NEAREST
	# Update
	palette = palette
	aux_palette = aux_palette
	light_palmap = light_palmap
	mono_palmap = mono_palmap
	palette_index = 0

func _update_image():
	if pal_img and pal_texture:
		if palette and current_data == palette:
			if palette_index >= 0 and palette_index < palette.palettes.size():
				for y in range(16):
					for x in range(16):
						pal_img.set_pixel(x,y, palette.palettes[palette_index][(y * 16) + x])
				pal_texture.update(pal_img)
		elif aux_palette and current_data == aux_palette:
			pal_img.fill(Color.TRANSPARENT)
			if aux_palette_index >= 0 and aux_palette_index < aux_palette.aux_palettes.size():
				for x in range(16):
					pal_img.set_pixel(x, 0, palette.palettes[0][aux_palette.aux_palettes[aux_palette_index][x]])
				pal_texture.update(pal_img)
		elif light_palmap and current_data == light_palmap:
			if light_palmap_index >= 0 and light_palmap_index < light_palmap.palette_maps.size():
				for y in range(16):
					for x in range(16):
						pal_img.set_pixel(x,y, palette.palettes[0][light_palmap.palette_maps[light_palmap_index][(y * 16) + x]])
				pal_texture.update(pal_img)
		elif mono_palmap and current_data == mono_palmap:
			if mono_palmap_index >= 0 and mono_palmap_index < mono_palmap.palette_maps.size():
				for y in range(16):
					for x in range(16):
						pal_img.set_pixel(x,y, palette.palettes[0][mono_palmap.palette_maps[mono_palmap_index][(y * 16) + x]])
				pal_texture.update(pal_img)

func _on_option_button_palette_item_selected(index: int) -> void:
	palette_index = index

func _on_option_button_aux_palette_item_selected(index: int) -> void:
	aux_palette_index = index

func _on_option_button_palette_pressed() -> void:
	palette_index = palette_index

func _on_option_button_aux_palette_pressed() -> void:
	aux_palette_index = aux_palette_index


func _on_option_button_light_pal_map_item_selected(index: int) -> void:
	light_palmap_index = index


func _on_option_button_light_pal_map_pressed() -> void:
	light_palmap_index = light_palmap_index


func _on_option_button_mono_pal_map_item_selected(index: int) -> void:
	mono_palmap_index = index


func _on_option_button_mono_pal_map_pressed() -> void:
	mono_palmap_index = mono_palmap_index
