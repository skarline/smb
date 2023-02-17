extends Block

class_name QuestionBlock

@export var is_invisible: bool = false

func _ready():
	super()

	if is_invisible:
		sprite.visible = false

func hit(body: Node):
	super(body)

	if cannot_hit:
		return

	if item:
		release_item()
	else:
		release_coin()
	
	set_empty()
