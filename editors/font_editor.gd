extends PanelContainer

var palette:Palette = null

var fonts:Array[UFont] = []:
	get(): return fonts
	set(val):
		fonts = val
		if is_inside_tree():
			%OptionButtonFonts.clear()
			for i in range(fonts.size()):
				%OptionButtonFonts.add_item(str(fonts[i].font_name))
			
var font_index:int = 0:
	get(): return font_index
	set(val):
		font_index = val
		_update_texture()

func _ready():
	fonts = fonts
	font_index = font_index
	%Sprite2D.texture_filter = TEXTURE_FILTER_NEAREST

func _update_texture():
	if is_inside_tree():
		var ufont:UFont = fonts[font_index]
		var texture:ImageTexture = ufont.create_texture(%TextEdit.text)
		%Sprite2D.texture = texture
		%Sprite2D.material.set_shader_parameter("palette_texture", palette.texture)
		%Sprite2D.material.set_shader_parameter("palette_index", 0)
		%Sprite2D.material.set_shader_parameter("has_mapper", false)
		%Sprite2D.material.set_shader_parameter("has_aux_palette", false)
			
		
		
		
