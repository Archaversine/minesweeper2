extends Node2D

@onready var damage = 40

# Called when the node enters the scene tree for the first time.
func _ready():
	$ExplosionPlayer.current_animation = "explode"
	$ExplosionPlayer.active = true;

func _on_explosion_player_animation_finished(anim_name):
	if anim_name == "explode":
		queue_free()

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		body.modify_health(-damage)	
