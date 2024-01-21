class_name BrickBlock
extends QuestionBlock

var debris_scene = preload("res://scenes/particles/brick_block_debris.tscn")

const DEBRIS_VERTICAL_VELOCITY: float = -360.0


func on_hit(body: Node):
	var _item = item
	super(body)

	if _item == Item.NONE:
		if body is Player and body.state == Player.State.SMALL:
			return

		spawn_debris()
		queue_free()


func spawn_debris():
	var debris = debris_scene.instantiate()
	debris.position = position
	debris.velocity.y = DEBRIS_VERTICAL_VELOCITY
	add_sibling(debris)
