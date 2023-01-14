extends CharacterBody2D

# Physics
const MAX_SPEED = 174.93
const MAX_WALK_SPEED = 106.67
const MIN_SKID_SPEED = 38.4

const MIN_WALK_SPEED = 5.07

const WALK_ACCELERATION = 152
const RUN_ACCELERATION = 228
const WALK_FRICTION = 208
const SKID_FRICTION = 416

const JUMP_SPEED = -100.0

# Input
var is_facing_left = false
var is_running = false
var is_jumping = false
var is_falling = false
var is_skiding = false

var direction = 0.0
var gravity = 0.0
var h_speed = 0.0

# Nodes
@onready var sprite = $Sprite

func _process(delta):
	animate(delta)

func _physics_process(delta):
	handle_input()
	
	handle_jump(delta)
	handle_move(delta)

	move_and_slide()

func handle_input():
	direction = Input.get_axis("move_left", "move_right")
	is_running = Input.is_action_pressed("run")

func handle_jump(delta: float):
	var jump_speed = -163.84
	var jumping_gravity = 512.0
	var falling_gravity = 1792.0
	
	is_falling = velocity.y > 0.0
	
	if velocity.x > 40.96:
		jumping_gravity = 480.0
		falling_gravity = 1536.0
	elif velocity.x > 94.71:
		jump_speed = -204.80
		jumping_gravity = 640.0
		falling_gravity = 2304.0
	
	if is_on_floor():
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_speed * 1.55
			gravity = jumping_gravity
	else:
		var target_gravity = falling_gravity if is_falling else jumping_gravity
		
		gravity = move_toward(gravity, target_gravity, 3000 * delta)
		
		velocity.y += gravity * delta

func handle_move(delta: float):
	var target_speed = 0.0
	
	if velocity.x:
		is_skiding = sign(velocity.x) < 0 != is_facing_left
		
		if is_skiding:
			if abs(velocity.x) < MIN_SKID_SPEED:
				velocity.x = 0.0
	else:
		is_skiding = false
	
	if direction:
		var max_speed = MAX_WALK_SPEED
		var acceleration = SKID_FRICTION
		
		if not is_skiding:
			if is_running:
				max_speed = MAX_SPEED
				acceleration = RUN_ACCELERATION
			else:
				acceleration = WALK_ACCELERATION
		
		target_speed = direction * max_speed
		
		if is_on_floor():
			is_facing_left = direction < 0
		
		velocity.x = move_toward(velocity.x, target_speed, acceleration * delta)
	elif is_on_floor():
		if abs(velocity.x) < MIN_WALK_SPEED:
			velocity.x = 0.0
		else:
			velocity.x = move_toward(velocity.x, 0, WALK_FRICTION * delta)
	
	h_speed = abs(velocity.x) / MAX_SPEED

func animate(delta: float):
	sprite.flip_h = is_facing_left
	sprite.speed_scale = 0 if is_falling else h_speed * 5
	
	if is_on_floor():
		if velocity.x:
			if is_skiding:
				sprite.play("skid")
			else:
				sprite.play("walk")
		else:
			sprite.play("idle")
	else:
		sprite.play("jump")
