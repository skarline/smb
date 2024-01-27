extends CharacterBody2D

class_name Player

# Physics

# Formulae to convert the original game's sub-sub-sub pixels per frame units to
# pixels per second:

# Speed: x * (15 / 1024)
# Acceleration: x * (225 / 256)

const MIN_SPEED = 4.453125
const MAX_SPEED = 153.75
const MAX_WALK_SPEED = 93.75
const MAX_FALL_SPEED = 270.0
const MAX_FALL_SPEED_CAP = 240.0
const MIN_SLOW_DOWN_SPEED = 33.75

const WALK_ACCELERATION = 133.59375
const RUN_ACCELERATION = 200.390625
const WALK_FRICTION = 182.8125
const SKID_FRICTION = 365.625

# Jump physics vary based on horizontal speed thresholds
const JUMP_SPEED = [-240.0, -240.0, -300.0]
const LONG_JUMP_GRAVITY = [450.0, 421.875, 562.5]
const GRAVITY = [1575.0, 1350.0, 2025.0]

const SPEED_THRESHOLDS = [60, 138.75]

const STOMP_SPEED = 240.0
const STOMP_SPEED_CAP = -60.0

const COOLDOWN_TIME_SEC = 3.0

# Nodes
@onready var camera = get_node_or_null("Camera")

# Input
var is_facing_left = false
var is_running = false
var is_jumping = false
var is_falling = false
var is_skiding = false
var is_crouching = false

var _old_velocity = Vector2.ZERO

var input_axis = Vector2.ZERO
var speed_scale = 0.0

var min_speed = MIN_SPEED	
var max_speed = MAX_WALK_SPEED
var acceleration = WALK_ACCELERATION

var speed_threshold: int = 0

enum State { SMALL, BIG, FIRE }

var state = State.SMALL:
	set(value):
		if state != value:
			state = value
			
			match state:
				State.SMALL:
					transition_sprite.animation = "shrink"
				State.BIG:
					transition_sprite.animation = "grow"
			
			transition_sprite.flip_h = sprite.flip_h
			animation_player.play("transition")
			
			Physics.disable()

var has_cooldown = false

var collected_item_ref: Node = null

# Nodes
@onready var sprite = $SmallSprite

@onready var small_sprite: AnimatedSprite2D = $SmallSprite
@onready var big_sprite: AnimatedSprite2D = $BigSprite
@onready var transition_sprite: AnimatedSprite2D = $TransitionSprite

@onready var hitbox: Area2D = $Hitbox
@onready var small_hitbox_shape: CollisionShape2D = $Hitbox/Small
@onready var big_hitbox_shape: CollisionShape2D = $Hitbox/Big

@onready var small_collision_shape: CollisionPolygon2D = $SmallCollisionShape
@onready var big_collision_shape: CollisionPolygon2D = $BigCollisionShape

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	_update_tree()

func _process(_delta):
	process_input()
	process_animation()

func _physics_process(delta):
	process_jump(delta)
	process_walk(delta)
	process_bounds_collision()
	
	_old_velocity = velocity

	move_and_slide()
	handle_last_collision()

func process_input():
	input_axis.x = Input.get_axis("move_left", "move_right")
	input_axis.y = Input.get_axis("move_up", "move_down")

	var was_crouching = is_crouching
	
	if is_on_floor():
		is_running = Input.is_action_pressed("run")
		is_crouching = Input.is_action_pressed("move_down")

		if is_crouching and input_axis.x:
			is_crouching = false
			input_axis.x = 0.0
	
	if is_crouching != was_crouching:
		_update_tree()

func process_jump(delta: float):
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			is_jumping = true
			
			var speed = abs(velocity.x)

			speed_threshold = SPEED_THRESHOLDS.size()

			for i in SPEED_THRESHOLDS.size():
				if speed < SPEED_THRESHOLDS[i]:
					speed_threshold = i
					break
			
			velocity.y = JUMP_SPEED[speed_threshold]
	else:
		var gravity = GRAVITY[speed_threshold]
		
		if Input.is_action_pressed("jump") and not is_falling:
			gravity = LONG_JUMP_GRAVITY[speed_threshold]
		
		velocity.y = velocity.y + gravity * delta
		
		if velocity.y > MAX_FALL_SPEED:
			velocity.y = MAX_FALL_SPEED_CAP
	
	if velocity.y > 0:
		is_jumping = false
		is_falling = true
	elif is_on_floor():
		is_falling = false

func process_walk(delta: float):
	if input_axis.x:
		if is_on_floor():
			if velocity.x:
				is_facing_left = input_axis.x < 0.0
				is_skiding = velocity.x < 0.0 != is_facing_left
				
			if is_skiding:
				min_speed = MIN_SLOW_DOWN_SPEED
				max_speed = MAX_WALK_SPEED
				acceleration = SKID_FRICTION
			elif is_running:
				min_speed = MIN_SPEED
				max_speed = MAX_SPEED
				acceleration = RUN_ACCELERATION
			else:
				min_speed = MIN_SPEED
				max_speed = MAX_WALK_SPEED
				acceleration = WALK_ACCELERATION
		elif is_running and abs(velocity.x) > MAX_WALK_SPEED:
			max_speed = MAX_SPEED
		else:
			max_speed = MAX_WALK_SPEED
		
		var target_speed = input_axis.x * max_speed
		
		velocity.x = move_toward(velocity.x, target_speed, acceleration * delta)
	elif is_on_floor() and velocity.x:
		if not is_skiding:
			acceleration = WALK_FRICTION
		
		if input_axis.y:
			min_speed = MIN_SLOW_DOWN_SPEED
		else:
			min_speed = MIN_SPEED
		
		if abs(velocity.x) < min_speed:
			velocity.x = 0.0
		else:
			velocity.x = move_toward(velocity.x, 0.0, acceleration * delta)
	
	if abs(velocity.x) < MIN_SLOW_DOWN_SPEED:
		is_skiding = false
	
	speed_scale = abs(velocity.x) / MAX_SPEED

func process_bounds_collision():
	if not camera:
		return

	const HALF_TILE = 8

	var _old_position = global_position

	global_position.x = clamp(
		global_position.x,
		camera.limit_left + HALF_TILE,
		camera.limit_right - HALF_TILE
	)

	if global_position.x != _old_position.x:
		velocity.x = 0.0

func handle_last_collision():
	var collision = get_last_slide_collision()
	
	if not collision:
		return
	
	var normal = collision.get_normal() * -1.0 # normal is relative to the player

	# keep the y velocity when colliding with a corner
	if normal != round(normal):
		velocity.y = _old_velocity.y

	# head collision
	if normal == Vector2.UP:
		var collider = collision.get_collider()
		
		if collider.has_method("hit"):
			collider.hit(self)

func process_animation():
	sprite.flip_h = is_facing_left
	sprite.speed_scale = max(1.75, speed_scale * 5.0)
	
	if is_falling:
		sprite.stop()
	elif is_crouching and state:
		sprite.play("crouch")
	elif is_jumping:
		sprite.play("jump")
	elif is_skiding:
		sprite.play("skid")
	elif input_axis.x or velocity.x:
		sprite.play("walk")
	else:
		sprite.play("idle")

	if has_cooldown:
		modulate.a = 0.0 if modulate.a else 1.0
	else:
		modulate.a = 1.0

func _update_tree():
	var is_small = not state
	var is_crouching_or_small = is_crouching or is_small

	sprite = small_sprite if is_small else big_sprite

	small_sprite.visible = is_small	
	big_sprite.visible = not is_small

	big_collision_shape.disabled = is_crouching_or_small
	big_hitbox_shape.disabled = is_crouching_or_small

	small_collision_shape.disabled = not is_crouching_or_small
	small_hitbox_shape.disabled = not is_crouching_or_small

func transform(to_state: State):
	state = to_state
	

func take_hit():
	if state == State.SMALL:
		# TODO: handle death
		pass
	else:
		transform(state - 1)
		_cooldown()

func _cooldown():
	has_cooldown = true
	get_tree().create_timer(COOLDOWN_TIME_SEC).connect("timeout", func(): has_cooldown = false)

func _on_transition_started():
	sprite.visible = false
	transition_sprite.visible = true

	if collected_item_ref:
		collected_item_ref.queue_free()
		collected_item_ref = null

func _on_transition_finished():
	var animation_name = sprite.animation

	_update_tree()
	
	if sprite.sprite_frames.has_animation(animation_name):
		sprite.play(animation_name)
	else:
		sprite.play("idle")

	transition_sprite.visible = false

func _on_hitbox_area_entered(area: Area2D):
	var body = area.get_parent()
	
	if body.is_in_group("enemies"):
		if not body.is_alive:
			return

		var stomp = velocity.y > 0 and hitbox.global_position.y < area.global_position.y

		if stomp:
			if body.has_method("stomp"):
				body.stomp()
				velocity.y = fmod(velocity.y, STOMP_SPEED_CAP) - STOMP_SPEED
		elif not has_cooldown:
			take_hit()

func _on_hitbox_body_entered(body: Node):
	if body.is_in_group("powerups"):
		collected_item_ref = body
		
		if body is RedMushroom:
			transform(State.BIG)

func _on_animation_player_animation_finished(_anim_name):
	Physics.enable()
