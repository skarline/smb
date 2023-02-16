extends CharacterBody2D

class_name Goomba

const SPEED = 32.0

var is_facing_left = true
var is_stomped = false

func _ready():
	$Sprite.play("default")

func _physics_process(delta):
	if is_stomped:
		return
	
	velocity.x = -SPEED if is_facing_left else SPEED
	velocity.y += Physics.GRAVITY * delta

	move_and_slide()

	handle_collision()

func handle_collision():
	var collision = get_last_slide_collision()

	if collision:
		var angle = round(collision.get_angle() * 180 / PI)
		
		# wall collision
		if angle == 90:
			change_direction()

func change_direction():
	is_facing_left = not is_facing_left

func on_stomp() -> bool:
	if is_stomped:
		return false
	
	$Sprite.play("stomp")
	$DeathTimer.start()

	is_stomped = true
	
	return true

func _on_hitbox_area_entered(area: Area2D):
	var body = area.get_parent()

	if body.is_in_group("enemies"):
		change_direction()

func _on_death_timer_timeout():
	queue_free()