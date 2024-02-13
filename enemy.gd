extends RigidBody2D

@onready var nav = $NavigationAgent2D

const SPEED = 200.0

var player

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if player == null:
		return
	
	nav.target_position = player.global_position
	
	var direction = nav.get_next_path_position() 
	direction = direction.normalized()
	
	position += direction * SPEED
