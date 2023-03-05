extends CharacterBody2D

class_name Goomba

var is_alive: bool = true

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var death_timer: Timer = $DeathTimer
@onready var walk_behavior: WalkBehavior = $WalkBehavior

func _ready():
	sprite.play("walk")

func _physics_process(_delta):
	if is_alive:
		move_and_slide()

func stomp():
	sprite.play("stomp")
	death_timer.start()

	is_alive = false
	
	return true

func _on_hitbox_area_entered(_area: Area2D):
	walk_behavior.change_direction()

func _on_death_timer_timeout():
	queue_free()
