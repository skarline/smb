extends CharacterBody2D

class_name Goomba

var is_stomped = false

func _ready():
	$Sprite.play("default")

func _physics_process(_delta):
	if not is_stomped:
		move_and_slide()

func on_stomp() -> bool:
	if is_stomped:
		return false
	
	$Sprite.play("stomp")
	$DeathTimer.start()

	is_stomped = true
	
	return true

func _on_hitbox_area_entered(_area: Area2D):
	$WalkBehavior.change_direction()

func _on_death_timer_timeout():
	queue_free()
