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
		# TODO: destroy if hit by big mario
		pass
