extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.current_animation = "fade_in"
	$AnimationPlayer.active = true

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fade_in":
		get_tree().change_scene_to_file("res://main_menu.tscn")
