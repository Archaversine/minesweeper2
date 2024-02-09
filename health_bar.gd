extends ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func set_health(amount):
	value = min(max_value, amount)
	var ratio = value / max_value
	
	if ratio >= 0.8:
		get_theme_stylebox("fill").set("bg_color", Color(0, 255, 0))
	elif ratio >= 0.4:
		get_theme_stylebox("fill").set("bg_color", Color(200, 50, 0))
	else:
		get_theme_stylebox("fill").set("bg_color", Color(255, 0, 0))

func modify_health(amount):
	set_health(value + amount)
