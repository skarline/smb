extends Node

class_name WalkBehavior

@export var speed: float = 32.0
@export var is_facing_left: bool = false
@export var handle_movement: bool = false

@onready var parent = get_parent()

func _physics_process(delta: float):
	handle_collision()

	parent.velocity.x = -speed if is_facing_left else speed
	parent.velocity.y += min(Physics.MAX_FALL_SPEED, Physics.GRAVITY * delta)

	if handle_movement:
		parent.move_and_slide()

func handle_collision():
	var collision = parent.get_last_slide_collision()

	if collision:
		var normal = collision.get_normal()

		if normal.x:
			is_facing_left = normal.x < 0

func change_direction():
	is_facing_left = not is_facing_left
