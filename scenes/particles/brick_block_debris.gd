extends Particle

const SPEED: float = sqrt(7200)  # 60 px per second in both axis


func _physics_process(delta):
	super(delta)
	for child in get_children():
		child.position += child.position.normalized() * SPEED * delta
