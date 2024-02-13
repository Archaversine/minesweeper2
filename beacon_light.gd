extends PointLight2D

var die = false

# Called when the node enters the scene tree for the first time.
func _ready():
	color.a = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if die:
		color.a = lerpf(color.a, 0, 0.2)
	else: 
		color.a = lerpf(color.a, 1, 0.05)
	
		if color.a <= 0.01:
			queue_free()
