extends AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	current_animation = "explode"
	active = true;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_animation_finished(anim_name):
	if anim_name == "explode":
		queue_free()
