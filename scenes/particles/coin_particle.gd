extends Node2D

var velocity = Vector2(0, -320.0)

func _ready():
	$Sprite.play("default")

func _physics_process(delta):
	velocity.y += min(Physics.GRAVITY * delta, 400)
	
	position += velocity * delta

func _on_timer_timeout():
	queue_free()
