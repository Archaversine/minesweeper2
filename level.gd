extends Node2D

@onready var mine_tiles = $MineTiles
@onready var player = $Player

# Called when the node enters the scene tree for the first time.
func _ready():
	var exit_light = load("res://beacon_light.tscn").instantiate()
	exit_light.modulate = Color("ffffff")
	exit_light.global_position = mine_tiles.get_exit_pos()
	exit_light.energy = 5
	exit_light.scale = Vector2(5, 5)
	add_child(exit_light)
	
	var limit = mine_tiles.bottom_right_camera_bound()

	player.camera.limit_right = limit.x 
	player.camera.limit_bottom = limit.y
	
	player.camera.position_smoothing_enabled = false
	player.global_position = mine_tiles.spawn_pos()
	player.camera.align()
	player.camera.position_smoothing_enabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player_touching_exit():
		player.run_physics = false
		$AnimationPlayer.current_animation = "fade_out_win"
		$AnimationPlayer.active = true
	
	if Input.is_action_just_pressed("mine_tile"):
		var mouse_pos = get_global_mouse_position()
		
		if player_can_reach(mouse_pos):
			mine_tiles.mine_tile(mouse_pos)
	elif Input.is_action_just_pressed("flag_tile"):
		var mouse_pos = get_global_mouse_position()
		
		if player_can_reach(mouse_pos):
			mine_tiles.flag_tile(mouse_pos)

func player_can_reach(global_coords: Vector2):
	var d = global_coords.distance_squared_to(player.global_position)
	return d <= player.reach * player.reach

func _on_player_player_die():
	get_tree().change_scene_to_file("res://game_over.tscn")

func _on_mine_tiles_explosion():
	player.add_cam_trauma(1)
	mine_tiles.refill_tiles(mine_tiles, 50 * 6) # roughly 6 tiles

func player_touching_exit():
	return mine_tiles.is_exit_pos(player.global_position)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fade_out_win":
		get_tree().change_scene_to_file("res://win_screen.tscn")
