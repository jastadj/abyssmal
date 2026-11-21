extends PanelContainer

const SPRITE_SCALE:float = 16.0

var pmap:PaletteMap = null

func _ready():
	
	var img_size:Vector2i = Vector2i(256,256)
	var img:Image = Image.create(img_size.x, img_size.y, false, Image.FORMAT_R8)
	var r:float
	var i:int = 0
	for y in range(img_size.y):
		for x in range(img_size.x):
			r = float(i%256) / 255.0
			img.set_pixel(x, y, Color(r, 0.0, 0.0))
			i += 1
			
	
	var texture:ImageTexture = ImageTexture.create_from_image(img)
	#%Sprite2D.texture = texture
	%Sprite2D.texture = pmap.texture
	%Sprite2D.texture_filter = TEXTURE_FILTER_NEAREST
	%Sprite2D.scale = Vector2(1,1) * SPRITE_SCALE
	#%Sprite2D.material.set_shader_parameter("palette_texture", pmap.texture)
