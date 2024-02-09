extends CPUParticles2D

func _ready():
	emitting = true

func _process(delta):
	color.a = lerpf(color.a, 0, 0.1)

func _on_finished():
	queue_free()
