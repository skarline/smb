extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _physics_process(delta):
	handle_gravity(delta)
	handle_jump(delta)
	handle_move(delta)

	move_and_slide()

func handle_gravity(delta: float):
	if not is_on_floor():
		velocity.y += Global.gravity * delta

func handle_jump(_delta: float):
	if is_on_floor():
		pass
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

func handle_move(_delta: float):
	var direction = Input.get_axis("move_left", "move_right")

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
