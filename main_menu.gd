extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.current_animation = "fade_in"
	$AnimationPlayer.active = true

