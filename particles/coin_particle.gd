extends Node2D

const LIFESPAN_SEC = 0.5

var velocity = Vector2(0, -340.0)


func _ready():
	$Sprite.play("default")
	get_tree().create_timer(LIFESPAN_SEC).connect("timeout", func(): queue_free())


func _physics_process(delta):
	velocity.y += min(Physics.GRAVITY * delta, Physics.MAX_FALL_SPEED)
	position += velocity * delta


func _on_timer_timeout():
	queue_free()
