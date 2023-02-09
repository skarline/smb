extends StaticBody2D

const CoinParticle = preload("res://scenes/particles/coin_particle.tscn")

var is_empty = false

@export var block_type: String

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
		
		add_child(CoinParticle.instantiate())
		
		is_empty = true
