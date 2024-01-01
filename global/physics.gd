extends Node

const GRAVITY = 1300.0
const MAX_FALL_SPEED = 270.0
const JUMP_SPEED = -240.0

@onready var _level = $"../Main/Level"

func _process(_delta):
	Engine.physics_ticks_per_second = round(DisplayServer.screen_get_refresh_rate())

func disable():
	_toggle_children_physics(_level, false)
	Logger.append("Physics disabled")

func enable():
	_toggle_children_physics(_level, true)
	Logger.append("Physics enabled")

func _toggle_children_physics(node: Node, value: bool):	
	for child in node.get_children():	
		child.set_physics_process(value)
		
		if child is AnimatedSprite2D:
			if value:
				child.play()
			else:
				child.stop()
		
		_toggle_children_physics(child, value)
