extends CharacterBody2D

signal player_die

@export var reach = 100.0
@export var max_health = 100.0
@export var health = 100.0

@onready var camera = $Camera2D

@export var cam_decay = 0.8
@export var cam_max_offset = Vector2(25, 25)
@export var cam_max_roll = 0.1 # Max rotation in radians

const SPEED = 300.0

var alive = true
var target_light_scale = 20

var cam_trauma = 0.0
var cam_trauma_power = 2 # Exponent

func _physics_process(delta):
	if not alive:
		return
	
	var dx = Input.get_axis("ui_left", "ui_right")
	var dy = Input.get_axis("ui_up", "ui_down")
	
	velocity.x = dx * SPEED 
	velocity.y = dy * SPEED
	
	var v = $PointLight2D.scale
	$PointLight2D.scale = Vector2(lerpf(v.x, target_light_scale, 0.1), lerpf(v.y, target_light_scale, 0.1))

	move_and_slide()

func _process(delta):
	if cam_trauma:
		cam_trauma = max(cam_trauma - cam_decay * delta, 0)
		shake()

func set_health(amount):
	$HealthBar.set_health(amount)
	update_health()

func modify_health(amount):
	$HealthBar.modify_health(amount)
	update_health()

func update_health():
	health = $HealthBar.value
	target_light_scale = 2 * health / 10
	
	if health <= 0:
		emit_signal("player_die")
		alive = false

func _on_regen_timer_timeout():
	modify_health(1)

func add_cam_trauma(amount):
	cam_trauma = min(cam_trauma + amount, 1.0)

func shake():
	var amount = pow(cam_trauma, cam_trauma_power)
	rotation = cam_max_roll * amount * randf_range(-1, 1)
	camera.offset.x = cam_max_offset.x * amount * randf_range(-1 ,1)
	camera.offset.y = cam_max_offset.y * amount * randf_range(-1 ,1)
