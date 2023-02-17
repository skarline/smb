extends CharacterBody2D

class_name Goomba

var is_stomped = false

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var death_timer: Timer = $DeathTimer
@onready var walk_behavior: WalkBehavior = $WalkBehavior

func _ready():
	sprite.play("default")

func _physics_process(_delta):
	if not is_stomped:
		move_and_slide()

func stomp() -> bool:
	if is_stomped:
		return false
	
	sprite.play("stomp")
	death_timer.start()

	is_stomped = true
	
	return true

func _on_hitbox_area_entered(_area: Area2D):
	walk_behavior.change_direction()

func _on_death_timer_timeout():
	queue_free()
