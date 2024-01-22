extends Area2D

@onready var collision: CollisionShape2D = get_child(0)


func _on_body_entered(body: PhysicsBody2D):
	for child in body.get_children():
		if child is Camera2D and child.has_method("set_bounds"):
			child.set_bounds(collision)
