extends TileMap

var selected_tile 
var tile_sprite
var tiles_count

var player_count = 2
var current_player = 1

var turn_count = 0

#grass_tiles ratio 		3 		0,25
#farm_tiles ratio 		1 		0,24
#forest_tiles ratio 	2		0,24
#mountain_tiles ratio 	4		0,17
#city_tiles ratio 		0 		0,05
#lake_tiles ratio 		5		0,05

var grass_count = 60
var farm_count = 57
var forest_count = 57
var mountain_count = 40
var city_count = 10
var pond_count = 10

var player_1_score = 0
var player_2_score = 0

var tile_dragged = false

var random_generator = RandomNumberGenerator.new()

onready var city_tile_texture = preload("res://tiles/new tiles/city1.png")
onready var farmland_texture = preload("res://tiles/new tiles/farmland1.png")
onready var forest_texture = preload("res://tiles/new tiles/forest.png")
onready var grass_texture = preload("res://tiles/new tiles/grass.png")
onready var mountain_texture = preload("res://tiles/new tiles/mountain_n.png")
onready var pond_texture = preload("res://tiles/new tiles/pond.png")

onready var game = get_parent()

onready var canvas_layer = get_node("../CanvasLayer/")

onready var player_1_label = get_node("../CanvasLayer/Player1Label")
onready var player_2_label = get_node("../CanvasLayer/Player2Label")

var red = Color(1, 0, 0)
var green = Color(0, 1, 0)
var gray = Color(0, 0, 0)


func change_labels_color(label1, label2, color1, color2):
	label1.set_self_modulate(color1)
	label2.set_self_modulate(color2)


func _ready():
	tiles_count = get_used_cells().size()

func choose_random_tile():

	while tiles_count > 0:
		var distribution_number = random_generator.randf()
		print(distribution_number)
		
		if distribution_number > 0.75 && distribution_number <= 1:
			if grass_count > 0:
				grass_count -= 1
				return 3
		
		elif distribution_number > 0.51 && distribution_number <= 0.75:
			if farm_count > 0:
				farm_count -= 1
				return 1
			
		elif distribution_number > 0.27 && distribution_number <= 0.51:
			if forest_count > 0:
				forest_count -= 1
				return 2
		
		elif distribution_number > 0.1 && distribution_number <= 0.27:
			if mountain_count > 0:
				mountain_count -= 1
				return 4
		
		elif distribution_number > 0.05 && distribution_number < 0.1:
			if 	city_count > 0:
				city_count -= 1
				return 0
		
		elif distribution_number >= 0 && distribution_number <= 0.05:
			if 	pond_count > 0:
				pond_count -= 1
				return 5

func new_tile_picked():
	
	selected_tile = choose_random_tile()
	
	tile_dragged = true
	tile_sprite = Sprite.new()
	tile_sprite.set_global_position(Vector2(125, 100))
	
	if selected_tile == 0:
		tile_sprite.set_texture(city_tile_texture)
	elif selected_tile == 1:
		tile_sprite.set_texture(farmland_texture)
	elif selected_tile == 2:
		tile_sprite.set_texture(forest_texture)
	elif selected_tile == 3:
		tile_sprite.set_texture(grass_texture)
	elif selected_tile == 4:
		tile_sprite.set_texture(mountain_texture)
	elif selected_tile == 5:
		tile_sprite.set_texture(pond_texture)
	
	canvas_layer.call_deferred("add_child", tile_sprite)
	

func _input(event):
	
	if event.is_action_pressed("left_click"):
		
		var local_mouse_pos = get_viewport().get_mouse_position()
		
		#selecting tiles
		if (local_mouse_pos.x < 315 && local_mouse_pos.y < 250):
			if tile_dragged == false && tiles_count > 0:
				new_tile_picked()
				
				if tiles_count == 3:
					var tile3 = get_node("../CanvasLayer/Control/RandomTile3")
					tile3.queue_free()
					
				if tiles_count == 2:
					var tile2 = get_node("../CanvasLayer/Control/RandomTile2")
					tile2.queue_free()
					
				if tiles_count == 1:
					var tile1 = get_node("../CanvasLayer/Control/RandomTile1")
					tile1.queue_free()
				
				tiles_count -= 1
		
		#dropping tiles
		if (local_mouse_pos.x > 315 && local_mouse_pos.y > 0) || (local_mouse_pos.x > 0 && local_mouse_pos.y > 250):
			if tile_dragged == true:
					
				var global_mouse_pos = game.get_global_mouse_position()
				global_mouse_pos.y -= 47

				var tile_map_pos = world_to_map(global_mouse_pos)

				var clicked_cell = get_cell(tile_map_pos.x, tile_map_pos.y)
				
				
				if clicked_cell == 6:
					if (selected_tile == 0 || selected_tile == 5):
						if check_for_nearby_tiles(tile_map_pos, selected_tile) == false:
							print("Cannot be placed. Bordering tile is a the same type.")
						else:
							set_cell(tile_map_pos.x, tile_map_pos.y, selected_tile)
							tile_dragged = false
							tile_sprite.queue_free()
							
							if current_player == 1:
								print(current_player)	
								current_player = 2
								turn_count += 1
								change_labels_color(player_1_label, player_2_label, red, green)
								print(current_player)	
							else:
								print(current_player)
								current_player = 1
								turn_count += 1
								change_labels_color(player_1_label, player_2_label, green, red)
								print(current_player)
					else:
						set_cell(tile_map_pos.x, tile_map_pos.y, selected_tile)
						tile_dragged = false
						tile_sprite.queue_free()
						
						if current_player == 1:
							print(current_player)
							current_player = 2
							turn_count += 1
							change_labels_color(player_1_label, player_2_label, red, green)
							print(current_player)
						else:
							print(current_player)	
							current_player = 1
							turn_count += 1
							change_labels_color(player_1_label, player_2_label, green, red)
							print(current_player)
						
	#dragging(snap)
	if event is InputEventMouseMotion:
		if tile_dragged == true:
			var mouse_pos = get_viewport().get_mouse_position()
			tile_sprite.set_global_position(Vector2(mouse_pos.x, mouse_pos.y))
			

func check_for_nearby_tiles(tile, tile_index):
		
	var oddness: bool
	
	if (int(tile.x) % 2) == 0:
		oddness = false
	else:
		oddness = true
	
	if !oddness:
		
		var tile_a = Vector2(tile.x-1, tile.y-1)
		var tile_b = Vector2(tile.x, tile.y-1)
		var tile_c = Vector2(tile.x+1, tile.y-1)
		var tile_d = Vector2(tile.x+1, tile.y)
		var tile_e = Vector2(tile.x, tile.y+1)
		var tile_f = Vector2(tile.x-1, tile.y)
		
		var bordering_tiles_odd = [tile_a, tile_b, tile_c, tile_d, tile_e, tile_f]
		
		for t in bordering_tiles_odd:
			var bordering_index = get_cellv(t)
			if bordering_index == tile_index:
				return false
	
		return true
	
	if oddness:
		
		var tile_g = Vector2(tile.x-1, tile.y)
		var tile_h = Vector2(tile.x, tile.y-1)
		var tile_i = Vector2(tile.x+1, tile.y)
		var tile_j = Vector2(tile.x+1, tile.y+1)
		var tile_k = Vector2(tile.x, tile.y+1)
		var tile_l = Vector2(tile.x-1, tile.y+1)
		
		var bordering_tiles_even = [tile_g, tile_h, tile_i, tile_j, tile_k, tile_l]
	
		for t in bordering_tiles_even:
			var bordering_index = get_cellv(t)
			if bordering_index == tile_index:
				return false
		
		return true
