class_name BrickBlock
extends QuestionBlock

var debris_scene = preload("res://particles/brick_block_debris.tscn")

const _BRICK_THEMES = {
	StageManager.StageTheme.OVERWORLD: preload("res://blocks/brick_block_frames_overworld.tres"),
	StageManager.StageTheme.UNDERGROUND:
	preload("res://blocks/brick_block_frames_underground.tres"),
}

const DEBRIS_VERTICAL_VELOCITY: float = -360.0


func on_hit(body: Node):
	var _item = item
	super(body)

	if _item == Item.NONE:
		if body is Player and body.state == Player.State.SMALL:
			return

		_spawn_debris()
		queue_free()


func _spawn_debris():
	var debris = debris_scene.instantiate()
	debris.position = position
	debris.velocity.y = DEBRIS_VERTICAL_VELOCITY
	add_sibling(debris)


func _set_theme(theme: StageManager.StageTheme):
	sprite.frames = _BRICK_THEMES[theme]
	sprite.play(sprite.animation)
