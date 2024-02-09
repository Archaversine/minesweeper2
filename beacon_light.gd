extends PointLight2D

# Called when the node enters the scene tree for the first time.
func _ready():
	color.a = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	color.a = lerpf(color.a, 1, 0.05)
