extends CharacterBody2D

# Physics
const MAX_SPEED = 174.93
const MAX_WALK_SPEED = 106.67
const MAX_FALL_SPEED = 273.07
const MIN_SKID_SPEED = 38.4
const MIN_WALK_SPEED = 5.07

const WALK_ACCELERATION = 152.0
const RUN_ACCELERATION = 228.0
const WALK_FRICTION = 208.0
const SKID_FRICTION = 416.0

# Jump physics vary based on horizontal speed thresholds
const JUMP_SPEED = [-273.07, -273.07, -341.33]
const LONG_JUMP_GRAVITY = [512.0, 480.0, 640.0]
const GRAVITY = [1792.0, 1536.0, 2304.0]

const SPEED_THRESHOLD_1 = 68.27
const SPEED_THRESHOLD_2 = 157.85

# Input
var is_facing_left = false
var is_running = false
var is_jumping = false
var is_falling = false
var is_skiding = false

var direction = 0.0
var speed_scale = 0.0

var max_speed = MAX_WALK_SPEED
var acceleration = WALK_ACCELERATION

var speed_threshold: int = 0

# Nodes
@onready var sprite = $Sprite
@onready var hitbox = $Hitbox

func _process(delta):
	animate(delta)

func _physics_process(delta):
	handle_input()
	
	handle_jump(delta)
	handle_walk(delta)
	
	move_and_slide()

func handle_input():
	direction = Input.get_axis("move_left", "move_right")
	is_running = Input.is_action_pressed("run")

func handle_jump(delta: float):
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			var speed = abs(velocity.x)
			
			if speed < SPEED_THRESHOLD_1:
				speed_threshold = 0
			elif speed < SPEED_THRESHOLD_2:
				speed_threshold = 1
			else:
				speed_threshold = 2
			
			velocity.y = JUMP_SPEED[speed_threshold]
	else:
		var gravity = GRAVITY[speed_threshold]
		
		if Input.is_action_pressed("jump") and not is_falling:
			gravity = LONG_JUMP_GRAVITY[speed_threshold]
		
		velocity.y = min(MAX_FALL_SPEED, velocity.y + gravity * delta)
	
	is_jumping = velocity.y < 0.0
	is_falling = velocity.y > 0.0

func handle_walk(delta: float):
	if direction:
		if is_on_floor():
			is_facing_left = direction < 0.0
			is_skiding = velocity.x < 0.0 != is_facing_left
			
			if is_skiding:
				max_speed = MAX_WALK_SPEED
				acceleration = SKID_FRICTION
			elif is_running:
				max_speed = MAX_SPEED
				acceleration = RUN_ACCELERATION
			else:
				max_speed = MAX_WALK_SPEED
				acceleration = WALK_ACCELERATION
		else:
			max_speed = max(abs(velocity.x), MAX_WALK_SPEED)
		
		var target_speed = direction * max_speed
		
		velocity.x = move_toward(velocity.x, target_speed, acceleration * delta)
	elif is_on_floor() and velocity.x:
		var min_speed = MIN_SKID_SPEED if is_skiding else MIN_WALK_SPEED
		
		if abs(velocity.x) < min_speed:
			velocity.x = 0.0
		else:
			velocity.x = move_toward(velocity.x, 0.0, WALK_FRICTION * delta)
		
		if not velocity.x:
			is_skiding = false
	
	speed_scale = abs(velocity.x) / MAX_SPEED

func animate(delta: float):
	sprite.flip_h = is_facing_left
	sprite.speed_scale = max(2.0, speed_scale * 5.0)
	
	if is_falling:
		sprite.stop()
	elif is_jumping:
		sprite.play("jump")
	elif is_skiding:
		sprite.play("skid")
	elif velocity.x:
		sprite.play("walk")
	else:
		sprite.play("idle")
