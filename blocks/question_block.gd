class_name QuestionBlock
extends StaticBody2D

signal hit_finished

enum Item { NONE, SINGLE_COIN, MULTI_COIN, RED_MUSHROOM_OR_FIRE_FLOWER, GREEN_MUSHROOM, STAR }

const _THEMES = {
	StageManager.StageTheme.OVERWORLD: preload("res://blocks/question_block_frames_overworld.tres"),
	StageManager.StageTheme.UNDERGROUND:
	preload("res://blocks/question_block_frames_underground.tres"),
}

const ON_HIT_VELOCITY = -140

const coin_particle_scene = preload("res://particles/coin_particle.tscn")
const red_mushroom_scene = preload("res://items/red_mushroom.tscn")

@export var item: Item = Item.NONE

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var hit_area: Area2D = $HitArea

var _hit: bool = false
var _is_empty: bool = false
var _velocity: float = 0
var _item_instance: Node = null


func _ready():
	_set_theme(StageManager.theme)
	StageManager.connect("theme_changed", _set_theme)


func _physics_process(delta):
	if not _hit:
		sprite.offset = Vector2.ZERO
		return

	_velocity += Physics.GRAVITY * delta
	sprite.offset.y += _velocity * delta

	if sprite.offset.y >= 0:
		_on_hit_finished()


func hit(body: Node):
	if _is_empty or _hit:
		return

	on_hit(body)


func on_hit(body: Node):
	for hit_body in hit_area.get_overlapping_bodies():
		if hit_body.has_method("hit"):
			hit_body.hit(self)

	_hit = true
	_velocity = ON_HIT_VELOCITY

	match item:
		Item.SINGLE_COIN:
			_item_instance = coin_particle_scene.instantiate()
		Item.RED_MUSHROOM_OR_FIRE_FLOWER:
			if body is Player and body.state != Player.State.SMALL:
				_item_instance = red_mushroom_scene.instantiate()  # TODO: fire flower
			else:
				_item_instance = red_mushroom_scene.instantiate()
		_:
			_item_instance = null

	if _item_instance:
		item = Item.NONE
		_is_empty = true
		sprite.play("empty")

		_item_instance.position = position + Vector2.UP * 16
		if "spawner" in _item_instance:
			_item_instance.spawner = self

		add_sibling(_item_instance)
		_item_instance = null


func _on_hit_finished():
	_hit = false
	hit_finished.emit()


func _set_theme(theme: StageManager.StageTheme):
	sprite.frames = _THEMES[theme]
	sprite.play(sprite.animation)


func _on_hit_area_body_entered(body):
	if _hit and body.has_method("hit"):
		body.hit(self)
