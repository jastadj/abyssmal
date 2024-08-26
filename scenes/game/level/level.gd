extends Node3D

@onready var tiles = $tiles
@onready var objects = $objects

var level = null

var palette
var aux_palettes = []

var object_textures = []
var floor_textures = []
var wall_textures = []
#$tiles/floor/Plane.get_active_material(0).set_shader_parameter("img", ImageTexture.create_from_image(System.cur_data["images"]["floor_32"][0]) )

func _ready():
	
	# get references
	palette = System.cur_data["palettes"]["main"][0]
	aux_palettes = System.cur_data["palettes"]["aux"]
	floor_textures = System.cur_data["textures"]["floor_32"]
	wall_textures = System.cur_data["textures"]["walls_64"]
	object_textures = System.cur_data["textures"]["objects"]
	
	#testing
	#$floor/Plane.get_active_material(0).set_shader_parameter("img", ImageTexture.create_from_image(System.cur_data["images"]["floor_32"][0]) )
	
func load_level(tgt_level:Dictionary):
		
	clear_level()
	
	level = tgt_level
	
	#print(level.keys())
	#print(level["textures"].keys())
	#print(level["textures"]["ceiling"])
	#print(level["tiles"][2])
	
	# ceiling texture index
	var ceiling_texture_index = level["textures"]["ceiling"]
	
	for y in range(0, level["length"]):
		var new_nodey = Node3D.new()
		new_nodey.name = str("y_",y)
		$tiles.add_child(new_nodey)
		for x in range(0, level["width"]):
			var new_nodex = preload("res://level_cell/level_cell.tscn").instantiate()
			var floor_texture_index = level["textures"]["floors"][level["tiles"][y][x]["floor"]]
			var wall_texture_index = level["textures"]["walls"][level["tiles"][y][x]["wall"]]
			
			new_nodex.name = str("x_",x)
			new_nodey.add_child(new_nodex)
			new_nodex.position = Vector3(x*System.TILE_SIZE, 0, y*System.TILE_SIZE)
			
			# get references to adjacent cells
			if(x != 0):
				var west_cell = new_nodey.get_node(str("x_",x-1))
				new_nodex.west = west_cell
				west_cell.east = new_nodex
			if(y != 0):
				var north_cell = $tiles.get_node(str("y_", y-1))
				if north_cell:
					north_cell = north_cell.get_node(str("x_",x))
				new_nodex.north = north_cell
				north_cell.south = new_nodex
							
			new_nodex.set_cell(level["tiles"][y][x]["type"], level["tiles"][y][x]["height"], floor_textures[floor_texture_index], wall_textures[wall_texture_index], floor_textures[ceiling_texture_index])
	
	for object in level["objects"]:
		if object["in_map"]:
			add_object(object)
	
func clear_level():
	
	for child in tiles.get_children():
		tiles.remove_child(child)
		child.queue_free()
		
	for child in objects.get_children():
		objects.remove_child(child)
		child.queue_free()

func add_object(obj):
	if object_textures[obj["id"]] != null:
		var new_obj = preload("res://scenes/game/level/object/object.tscn").instantiate()
		new_obj.set_object(obj)
		objects.add_child(new_obj)
		
