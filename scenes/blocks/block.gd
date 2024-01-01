extends StaticBody2D

class_name Block

const CoinParticle = preload("res://scenes/particles/coin_particle.tscn")

@export var item: PackedScene = null

@onready var contained_item_sprite: Sprite2D = $ContainedItemSprite
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var entity_detection_area: Area2D = $EntityDetectionArea
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var _item_instance: Node2D = null
var _is_hitting = false
var _is_empty = false

var cannot_hit = false

func _ready():
	sprite.play("default")

func hit(_body: Node):
	cannot_hit = _is_empty or _is_hitting

	if cannot_hit:
		return

	_is_hitting = true
	animation_player.play("hit")

	for entity in entity_detection_area.get_overlapping_bodies():
		if entity.has_method("hit"):
			entity.hit(self)
	
func set_empty():
	_is_empty = true
	sprite.play("empty")

func release_coin():
	add_child(CoinParticle.instantiate())

func release_item():
	_item_instance = item.instantiate()

	var item_sprite = _item_instance.get_node("Sprite")

	if not sprite:
		return

	if item_sprite is Sprite2D:
		contained_item_sprite.texture = item_sprite.texture
	elif item_sprite is AnimatedSprite2D:
		contained_item_sprite.texture = item_sprite.frame.texture

func _on_animation_player_animation_finished(anim_name: StringName):
	match anim_name:
		"hit":
			_is_hitting = false

			if item:
				contained_item_sprite.visible = true
				animation_player.play("release")
		"release":
			contained_item_sprite.visible = false
			_item_instance.position = position
			get_parent().add_child(_item_instance)

func _on_entity_detection_area_body_entered(body):
	if _is_hitting and body.has_method("hit"):
		body.hit(self)
