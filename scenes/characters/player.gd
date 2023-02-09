extends CharacterBody2D

# Formulae to convert the original game's sub-sub-sub pixels per frame units to
# pixels per second:

# Speed: x * (15 / 1024)
# Acceleration: x * (225 / 256)

# Physics
const MIN_SPEED = 4.453125
const MAX_SPEED = 153.75
const MAX_WALK_SPEED = 93.75
const MAX_FALL_SPEED = 270.0
const MAX_FALL_SPEED_CAP = 240.0
const MIN_SKID_SPEED = 33.75

const WALK_ACCELERATION = 133.59375
const RUN_ACCELERATION = 200.390625
const WALK_FRICTION = 182.8125
const SKID_FRICTION = 365.625

# Jump physics vary based on horizontal speed thresholds
const JUMP_SPEED = [-240.0, -240.0, -300.0]
const LONG_JUMP_GRAVITY = [450.0, 421.875, 562.5]
const GRAVITY = [1575.0, 1350.0, 2025.0]

const SPEED_THRESHOLD_1 = 60
const SPEED_THRESHOLD_2 = 138.75

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
	
	handle_collision()

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
		
		velocity.y = velocity.y + gravity * delta
		
		if velocity.y > MAX_FALL_SPEED:
			velocity.y = MAX_FALL_SPEED_CAP
	
	is_jumping = velocity.y < 0.0
	is_falling = not is_jumping and not is_on_floor()

func handle_walk(delta: float):
	if direction:
		if not velocity.y:
			if velocity.x:
				is_facing_left = direction < 0.0
				is_skiding = velocity.x < 0.0 != is_facing_left
			
			if is_skiding and abs(velocity.x) < MIN_SKID_SPEED:
				is_skiding = false
				velocity.x = 0.0
				
				return
			
			if is_skiding:
				max_speed = MAX_WALK_SPEED
				acceleration = SKID_FRICTION
			elif is_running:
				max_speed = MAX_SPEED
				acceleration = RUN_ACCELERATION
			else:
				max_speed = MAX_WALK_SPEED
				acceleration = WALK_ACCELERATION
		elif abs(velocity.x) > MAX_WALK_SPEED:
			max_speed = MAX_SPEED
		else:
			max_speed = MAX_WALK_SPEED
		
		var target_speed = direction * max_speed
		
		velocity.x = move_toward(velocity.x, target_speed, acceleration * delta)
	elif not velocity.y and velocity.x:
		if not is_skiding:
			acceleration = WALK_FRICTION
		
		if abs(velocity.x) < MIN_SPEED:
			velocity.x = 0.0
		else:
			velocity.x = move_toward(velocity.x, 0.0, acceleration * delta)
		
		if abs(velocity.x) < MIN_SKID_SPEED:
			is_skiding = false
	
	speed_scale = abs(velocity.x) / MAX_SPEED

func handle_collision():
	var collision = get_last_slide_collision()
	
	if not collision:
		return
	
	var angle = round(collision.get_angle() * 180 / PI)
	
	# head collision
	if angle == 180:
		var collider = collision.get_collider()
		
		if collider.has_method("on_hit"):
			collider.on_hit(self)

func animate(delta: float):
	sprite.flip_h = is_facing_left
	sprite.speed_scale = max(1.75, speed_scale * 5.0)
	
	if is_falling:
		sprite.stop()
	elif is_jumping:
		sprite.play("jump")
	elif is_skiding:
		sprite.play("skid")
	elif direction or velocity.x:
		sprite.play("walk")
	else:
		sprite.play("idle")

func _on_hitbox_body_entered(body):
	pass
