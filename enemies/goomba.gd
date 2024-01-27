class_name Goomba
extends CharacterBody2D

const SPEED: float = 30.0
const DESPAWN_TIME_SEC: float = 1.0

@onready var sprite: AnimatedSprite2D = $Sprite

@export var is_facing_left: bool = true

var is_alive: bool = true

const _THEMES = {
	StageManager.StageTheme.OVERWORLD: preload("res://enemies/goomba_frames_overworld.tres"),
	StageManager.StageTheme.UNDERGROUND: preload("res://enemies/goomba_frames_underground.tres"),
}


func _ready():
	_set_theme(StageManager.theme)
	StageManager.connect("theme_changed", _set_theme)


func _physics_process(delta):
	var collision = get_last_slide_collision()

	if collision:
		var normal = collision.get_normal()
		if normal.x:
			is_facing_left = normal.x < 0

	if is_alive:
		velocity.x = -SPEED if is_facing_left else SPEED
	else:
		velocity.x = 0.0

	velocity.y = min(Physics.MAX_FALL_SPEED, velocity.y + Physics.GRAVITY * delta)

	move_and_slide()


func stomp():
	sprite.play("stomp")
	is_alive = false

	get_tree().create_timer(DESPAWN_TIME_SEC).connect("timeout", queue_free)


func _set_theme(theme: StageManager.StageTheme):
	sprite.frames = _THEMES[theme]
	sprite.play(sprite.animation)


func _on_hitbox_area_entered(area: Area2D):
	var body = area.get_parent()

	if body is Player and body.has_cooldown:
		return

	is_facing_left = not is_facing_left


func _on_death_timer_timeout():
	queue_free()
