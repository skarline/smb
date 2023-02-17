extends Node

@export var speed: float = 32.0
@export var is_facing_left: bool = false
@export var handle_movement: bool = false

@onready var parent = get_parent()

func _physics_process(delta: float):
	handle_collision()

	parent.velocity.x = -speed if is_facing_left else speed
	parent.velocity.y += Physics.GRAVITY * delta

	if handle_movement:
		parent.move_and_slide()

func handle_collision():
	var collision = parent.get_last_slide_collision()

	if collision:
		var angle = round(collision.get_angle() * 180 / PI)
		
		# wall collision
		if angle == 90:
			change_direction()

func change_direction():
	is_facing_left = not is_facing_left