extends TileMap

signal explosion

@export var generate = true

@export var grid_size = 60

@export var dark_thickness = 15
@export var spawn_area = 5

@export var light_mine_chance = 0.27
@export var dark_mine_chance = 0.2

@export var beacon_chance = 0.025
@export var refill_chance = 0.2
@export var enemy_chance = 0.2

var mines = {} 
var numbers = {}
var pickaxe = null
var beacons = {}
var exit_tile = null

var number_colors = {
	1: '004fff',
	2: '068d00',
	3: 'e90000',
	4: '003abb',
	5: '7d0000',
	6: '009282',
	7: 'cddf00',
	8: '4b0056',
}

# Called when the node enters the scene tree for the first time.
func _ready():

	if not generate:
		return

	# Place outline
	for x in range(grid_size):
		for y in range(grid_size):
			var pos = Vector2i(x, y)
			
			if x == 0 or x == grid_size - 1 or y == 0 or y == grid_size - 1:
				set_cell(0, pos, 0, Vector2i(0, 4), 0)
			elif x <= dark_thickness or x >= grid_size - dark_thickness + 1 or \
				 y <= dark_thickness or y >= grid_size - dark_thickness + 1:
				set_cell(0, pos, 0, Vector2i(0, 1), 0)
			elif x <= grid_size / 2 - spawn_area / 2 - 1 or x >= grid_size / 2 + spawn_area / 2 + 1 or \
				 y <= grid_size / 2 - spawn_area / 2 - 1 or y >= grid_size / 2 + spawn_area / 2 + 1:
				set_cell(0, pos, 0, Vector2i(0, 0), 0)
			else:
				set_cell(0, pos, 0, Vector2i(1, 0), 0)

	# Place mines
	for tile in get_used_cells_by_id(0, -1, Vector2i.ZERO, 0):
		if randf() <= light_mine_chance:
			mines[tile] = 1
	
	for tile in get_used_cells_by_id(0, -1, Vector2i(0, 1), 0):
		if randf() <= dark_mine_chance:
			mines[tile] = 1

	# Place pickaxe
	var candidates = get_used_cells_by_id(0, -1, Vector2i.ZERO, 0)
	pickaxe = candidates.pick_random()
	mines.erase(pickaxe)
	
	# Place exit
	var dark_tiles = get_used_cells_by_id(0, 0, Vector2i(0, 1), 0)
	exit_tile = dark_tiles.pick_random()
	
	set_cell(0, exit_tile, 0, Vector2(1, 4), 0)

	# Calculate numbers
	for tile in mines.keys():
		increment_adjacent(tile)
	
	# Display numbers on already mined tiles
	for tile in get_used_cells_by_id(0, -1, Vector2i(1, 0), 0):
		if numbers.has(tile):
			set_cell(0, tile, 0, Vector2i(2 + numbers[tile], 0), 0)

func mine_tile(mouse_coords):
	var local_coords = to_local(mouse_coords)
	var tile = local_to_map(local_coords)
	
	if !get_cell_tile_data(0, tile).get_custom_data("mineable"):
		return
	
	if not $MiningSound.playing:
		$MiningSound.play()
		$StopMiningSound.start()
	else:
		$StopMiningSound.set_meta('refires', $StopMiningSound.get_meta("refires") + 1)
	
	var particles = load("res://tile_break_particles.tscn").instantiate()
	particles.global_position = to_global(map_to_local(tile))
	get_parent().add_child(particles)
	
	if beacons.has(tile):
		beacons[tile].destroy()
		beacons.erase(tile)
	
	if mines.has(tile):
		set_cell(0, tile, 0, Vector2i(2, 0), 0)
		
		# Spawn explosion
		var explosion = load("res://explosion.tscn").instantiate()
		explosion.global_position = to_global(map_to_local(tile))
		get_parent().add_child(explosion) 
		emit_signal("explosion")
	elif pickaxe != null and pickaxe == tile:
		set_cell(0, tile, 0, Vector2i(1, 3), 0)
		var s = tile_set.get_source(0) as TileSetAtlasSource
		s.get_tile_data(Vector2i(0, 1), 0).set_custom_data("mineable", true)
	elif numbers.has(tile):
		if get_cell_atlas_coords(0, tile) == Vector2i(0, 1):
			set_cell(0, tile, 0, Vector2i(2 + numbers[tile], 1), 0)
		else:
			set_cell(0, tile, 0, Vector2i(2 + numbers[tile], 0), 0)
		
		glow(numbers[tile], tile)
		
		var synth = load("res://synth_sound.tscn").instantiate()
		synth.global_position = to_global(map_to_local(tile))
		get_parent().add_child(synth)
	else:
		if get_cell_atlas_coords(0, tile) == Vector2i(0, 1):
			set_cell(0, tile, 0, Vector2i(1, 1), 0) # Dark tile
		else:
			if randf() <= beacon_chance:
				var beacon_light = load("res://beacon_light.tscn").instantiate()
				beacon_light.global_position = to_global(map_to_local(tile))
				
				set_cell(0, tile, 0, Vector2i(2, 2), 0) # beacon
				get_parent().add_child(beacon_light)
				beacons[tile] = beacon_light
			else:
				set_cell(0, tile, 0, Vector2i(1, 0), 0)

func flag_tile(mouse_coords):
	var local_coords = to_local(mouse_coords)
	var tile = local_to_map(local_coords)
	
	if !get_cell_tile_data(0, tile).get_custom_data("flaggable"):
		return
	
	var new_tile;
	
	match get_cell_atlas_coords(0, tile):
		Vector2i(0, 0): new_tile = Vector2i(11, 0) # Regular unmined
		Vector2i(11, 0): new_tile = Vector2i(12, 0) # Regular Red flag
		Vector2i(12, 0): new_tile = Vector2i(0, 0) # Regular Yellow flag
		
		Vector2i(0, 1): new_tile = Vector2i(11, 2) # Dark unmined
		Vector2i(11, 2): new_tile = Vector2i(12, 2) # Dark red flag
		Vector2i(12, 2): new_tile = Vector2i(0, 1) # Dark yellow flag
	
	set_cell(0, tile, 0, new_tile, 0)

func increment_tile(tile):
	if mines.has(tile):
		return
	
	numbers[tile] = numbers.get(tile, 0) + 1

func increment_adjacent(tile):
	var dirs = [Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]
	
	for dir in dirs:
		increment_tile(tile + dir)

func bottom_right_camera_bound():
	var scale_x = int(scale.x)
	var scale_y = int(scale.y)
	
	return tile_set.tile_size * grid_size * Vector2i(scale_x, scale_y)

func spawn_pos():
	var pos = Vector2(grid_size * scale.x, grid_size * scale.y) / 2.0
	return pos * Vector2(tile_set.tile_size) + Vector2(5, 5) * scale

func glow(number, pos):
	var g = load("res://glow.tscn").instantiate()
	
	g.global_position = to_global(map_to_local(pos))
	g.color = Color(number_colors[number])
	g.scale = Vector2(1, 1) * number * 5
	
	get_parent().add_child(g)

func refill_tiles(player, min_distance):
	for tile in get_used_cells(0):
		if get_cell_tile_data(0, tile) == null:
			continue
		
		if !get_cell_tile_data(0, tile).get_custom_data("refillable"):
			continue
		
		if randf() <= refill_chance:
			
			var global_tile = to_global(map_to_local(tile))
			
			var x2 = (player.global_position.x - global_tile.x) * (player.global_position.x - global_tile.x)
			var y2 = (player.global_position.y - global_tile.y) * (player.global_position.y - global_tile.y)
			
			if x2 + y2 <= min_distance * min_distance:
				continue
			
			if get_cell_tile_data(0, tile).get_custom_data("is_dark_tile"):
				set_cell(0, tile, 0, Vector2i(0, 1), 0)
			else:
				set_cell(0, tile, 0, Vector2i(0, 0), 0)
			
			if beacons.has(tile):
				beacons[tile].destroy()
				beacons.erase(tile)
		#elif randf() <= enemy_chance:
			#var enemy = load("res://enemy.tscn").instantiate()
			#enemy.global_position = to_global(map_to_local(tile))
			#enemy.player = player
			#get_parent().add_child(enemy)

func get_exit_pos():
	return to_global(map_to_local(exit_tile))

func is_exit_pos(pos):
	return get_cell_atlas_coords(0, local_to_map(to_local(pos))) == Vector2i(1, 4)

func _on_stop_mining_sound_timeout():
	var refires = $StopMiningSound.get_meta("refires")
	
	if refires > 0:
		$StopMiningSound.set_meta("refires", refires - 1)
		$StopMiningSound.start()
		return
	
	var pos = $MiningSound.get_playback_position()
	$MiningSound.stop()
	$MiningSound.seek(pos)
