extends CharacterBody2D

# Physics
const MAX_SPEED = 110.0
const JUMP_VELOCITY = -100.0
const FRICTION = 180.0
const SKID_FRICTION_MULTIPLIER = 1.5
const WALK_SPEED_MULTIPLIER = 0.6
const MIN_SPEED_TO_SKID = 30.0

# Input
var is_running = false
var is_facing_left = false
var is_skiding = false

var direction = 0.0

# Nodes
@onready var sprite = $Sprite

func _process(delta):
	handle_input()
	animate()

func _physics_process(delta):
	handle_gravity(delta)
	handle_jump(delta)
	handle_move(delta)

	move_and_slide()

func handle_input():
	direction = Input.get_axis("move_left", "move_right")
	is_running = Input.is_action_pressed("run")

func handle_gravity(delta: float):
	if not is_on_floor():
		velocity.y += Global.gravity * delta

func handle_jump(_delta: float):
	if is_on_floor():
		pass
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

func handle_move(delta: float):
	var target_speed = 0.0
	var friction = FRICTION * delta
	var facing_opposite = velocity.x and sign(velocity.x) < 0 != is_facing_left
	
	if facing_opposite:
		is_skiding = abs(velocity.x) > MIN_SPEED_TO_SKID
	
		if is_skiding:
			friction *= SKID_FRICTION_MULTIPLIER
		else:
			velocity.x = 0
	
	if direction:
		target_speed = direction * MAX_SPEED
		
		if not is_running:
			target_speed *= WALK_SPEED_MULTIPLIER
		
		if is_on_floor():
			is_facing_left = direction < 0
			is_skiding = sign(direction) != sign(velocity.x)
	
	velocity.x = move_toward(velocity.x, target_speed, friction)

func animate():
	sprite.flip_h = is_facing_left
	sprite.speed_scale = abs(velocity.x) / MAX_SPEED * 5
	
	if velocity.x:
		if is_skiding:
			sprite.play("skid")
		else:
			sprite.play("walk")
	else:
		sprite.play("idle")
