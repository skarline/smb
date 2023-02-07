extends Camera2D

var player: CharacterBody2D = null

func _ready():
	var player_node = $"../Player"
	
	if player_node:
		player = player_node

func _physics_process(delta):
	if not player:
		pass
	
	position.x = max(position.x, player.get_position().x + 8)
