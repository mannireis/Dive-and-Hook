extends Node2D

@export var tile_map_layer : TileMapLayer
@export var player : CharacterBody2D
@export var noise_height : NoiseTexture2D

const MAX_HITS := 1

var tile_hit_counts: Dictionary = {}
var noise : Noise
var width : int = 128
var height : int = 128
var source_id = 2
var land_atlas = Vector2i(1,1)
var sand_atlas = Vector2i(9,0)
var house_atlas = Vector2i(2,9)

func _ready() -> void:
	noise = noise_height.noise
	generate_world()
	generate_caves()
	generate_sand()
	tile_map_layer.set_cell(Vector2i(40, 40), 0, house_atlas)

func generate_world():
	randomize() 
	var seed = randi()  
	noise.seed = seed  
	var terrain_cells: Array[Vector2i] = []
	for x in range(width):
		var ground = abs(noise.get_noise_2d(x,0) * 10)
		for y in range(ground, height):
			var noise_val : float = noise.get_noise_2d(x,y)
			if noise_val >= -1:
				terrain_cells.append(Vector2i(x, y))  
	tile_map_layer.set_cells_terrain_connect(
		terrain_cells,
		0,  
		1     
	)

func generate_caves():
	randomize()
	for x in range(5, width - 5):
		for y in range(height - 83, height - 3):
			var noise_val: float = noise.get_noise_2d(x, y)
			if noise_val <= 0:
				tile_map_layer.erase_cell(Vector2(x, y))

func generate_sand():
	var band_width = 20
	var max_extra_height = 5 
	var terrain_cells: Array[Vector2i] = []
	for x in range(band_width):
		for y in range(height):
			tile_map_layer.erase_cell(Vector2(x, y))
	for x in range(width - band_width, width):
		for y in range(height):
			tile_map_layer.erase_cell(Vector2(x, y))
	for x in range(band_width):
		var ground = int(abs(noise.get_noise_2d(x, 0) * 10))
		ground = clamp(ground, 0, height - 1)
		var taper = float(x) / float(band_width - 1)
		var descent = int(max_extra_height * (1.0 - taper))
		var start_y = clamp(ground + descent, 0, height - 1)
		for y in range(start_y, height):
			var noise_val = noise.get_noise_2d(x, y)
			if noise_val >= -1:
				terrain_cells.append(Vector2i(x, y))  
	tile_map_layer.set_cells_terrain_connect(
		terrain_cells,
		0,  
		0     
	)
	for x in range(width - band_width, width):
		var ground = int(abs(noise.get_noise_2d(x, 0) * 10))
		ground = clamp(ground, 0, height - 1)
		var distance_from_edge = width - 1 - x
		var taper = float(distance_from_edge) / float(band_width - 1)
		var descent = int(max_extra_height * (1.0 - taper))
		var start_y = clamp(ground + descent, 0, height - 1)
		for y in range(start_y, height):
			var noise_val = noise.get_noise_2d(x, y)
			if noise_val >= -1:
				terrain_cells.append(Vector2i(x, y))  
	tile_map_layer.set_cells_terrain_connect(
		terrain_cells,
		0,  
		0     
	)

func _on_character_body_2d_break_block() -> void:
	if not player.inside_detector:
		return  
	var mouse_local_pos: Vector2 = tile_map_layer.to_local(get_global_mouse_position())
	var tile_coords: Vector2i = tile_map_layer.local_to_map(mouse_local_pos)
	var tile_data: TileData = tile_map_layer.get_cell_tile_data(tile_coords)
	if tile_data:
		if tile_data.has_custom_data("diggable"):
			var key = tile_coords
			if not tile_hit_counts.has(key):
				tile_hit_counts[key] = 1
			else:
				tile_hit_counts[key] += 1
			if tile_hit_counts[key] >= MAX_HITS:
				tile_map_layer.erase_cell(tile_coords)
				tile_map_layer.update_internals()
				tile_hit_counts.erase(key)
