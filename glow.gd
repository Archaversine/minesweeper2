extends PointLight2D

@onready var animation = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	#animation.current_animation = "fade_out"
	#animation.active = true
	pass
	
func _physics_process(delta):
	color.a = lerpf(color.a, 0, 0.02)
	
	if color.a <= 0.01:
		queue_free()
