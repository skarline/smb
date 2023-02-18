extends Player

@onready var standing_hitbox_shape: CollisionShape2D = $Hitbox/Shape
@onready var crouch_hitbox_shape: CollisionShape2D = $Hitbox/CrouchShape

@onready var standing_collision_shape: CollisionPolygon2D = $CollisionShape
@onready var crouch_collision_shape: CollisionPolygon2D = $CrouchCollisionShape

func _ready():
	is_big = true

func _physics_process(delta):
	super(delta)

func handle_input():
	var old_is_crouching = is_crouching

	super()
	
	if is_crouching != old_is_crouching:
		standing_hitbox_shape.disabled = is_crouching
		standing_collision_shape.disabled = is_crouching
		
		crouch_hitbox_shape.disabled = not is_crouching
		crouch_collision_shape.disabled = not is_crouching
