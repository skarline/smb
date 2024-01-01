extends Block

class_name BrickBlock

func hit(body: Node):
	super(body)

	if cannot_hit:
		return

	if item:
		release_item()
		set_empty()
	else:
		if body is Player and body.state != Player.State.SMALL:
			queue_free()
			# TODO: particles
