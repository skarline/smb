class_name Particle
extends Node2D

@export var lifespan_seconds: float = 3.0
@export var gravity: float = Physics.GRAVITY
@export var velocity: Vector2 = Vector2.ZERO


func _ready():
	get_tree().create_timer(lifespan_seconds).connect("timeout", queue_free)


func _physics_process(delta):
	velocity.y += Physics.GRAVITY * delta
	position += velocity * delta
