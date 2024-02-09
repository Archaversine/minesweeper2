extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var limit = $MineTiles.bottom_right_camera_bound()

	$Player.camera.limit_right = limit.x 
	$Player.camera.limit_bottom = limit.y
	
	$Player.camera.position_smoothing_enabled = false
	$Player.global_position = $MineTiles.spawn_pos()
	$Player.camera.align()
	$Player.camera.position_smoothing_enabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("mine_tile"):
		var mouse_pos = get_global_mouse_position()
		
		if player_can_reach(mouse_pos):
			$MineTiles.mine_tile(mouse_pos)
	elif Input.is_action_just_pressed("flag_tile"):
		var mouse_pos = get_global_mouse_position()
		
		if player_can_reach(mouse_pos):
			$MineTiles.flag_tile(mouse_pos)

func player_can_reach(global_coords: Vector2):
	var d = global_coords.distance_squared_to($Player.global_position)
	return d <= $Player.reach * $Player.reach

func _on_player_player_die():
	get_tree().change_scene_to_file("res://game_over.tscn")

func _on_mine_tiles_explosion():
	$Player.add_cam_trauma(1)
