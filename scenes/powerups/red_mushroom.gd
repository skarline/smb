class_name RedMushroom
extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite
@onready var collision_shape: CollisionShape2D = $CollisionShape

const SPEED: float = 60.0

var spawner: Node = null
var _left: bool = false


func _ready():
	if spawner is QuestionBlock:
		setup_block_animation()


func _physics_process(delta):
	var collision = get_last_slide_collision()

	if collision:
		var normal = collision.get_normal()
		if normal.x:
			_left = normal.x < 0

	velocity.x = -SPEED if _left else SPEED
	velocity.y += min(Physics.MAX_FALL_SPEED, Physics.GRAVITY * delta)

	move_and_slide()


func setup_block_animation():
	set_physics_process(false)
	sprite.visible = false
	collision_shape.disabled = true

	await spawner.hit_finished

	var _z_index = sprite.z_index
	sprite.z_index = -1
	sprite.visible = true
	sprite.offset = Vector2.DOWN * 16

	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "offset", Vector2.ZERO, 1)

	await tween.finished

	sprite.z_index = _z_index
	collision_shape.disabled = false
	set_physics_process(true)


func hit(body: Node):
	if body is QuestionBlock:
		velocity.y = Physics.JUMP_SPEED
		_left = body.position.x > position.x
