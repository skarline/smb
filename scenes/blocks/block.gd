extends StaticBody2D

const CoinParticle = preload("res://scenes/particles/coin_particle.tscn")

@export var item: PackedScene = null
@export var block_type: String

var is_empty = false
var item_instance: Node2D = null

func _ready():
	$Sprite.play("default")

func on_hit(_actor: Node):
	if is_empty:
		return
	
	if block_type == "brick":
		$AnimationPlayer.play("hit")
	else:
		$AnimationPlayer.play("hit")
		$Sprite.play("empty")
		
		# TODO: hit object on top
		
		if item:
			item_instance = item.instantiate()

			var sprite = item_instance.get_node("Sprite")

			if sprite is Sprite2D:
				$ItemSprite.texture = sprite.texture
		else:
			add_child(CoinParticle.instantiate())
		
		is_empty = true

func _on_animation_player_animation_finished(anim_name: StringName):
	if item:
		match anim_name:
			"hit":
				$ItemSprite.visible = true
				$AnimationPlayer.play("release")
			"release":
				$ItemSprite.visible = false
				item_instance.position = position
				get_parent().add_child(item_instance)
