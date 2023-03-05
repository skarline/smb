extends CharacterBody2D

class_name RedMushroom

@onready var walk_behavior: WalkBehavior = $WalkBehavior

func hit(body: Node):
	if body is Block:
		velocity.y = Physics.JUMP_SPEED
		walk_behavior.is_facing_left = global_position < body.global_position
