extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.current_animation = "fade_in"
	$AnimationPlayer.active = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
