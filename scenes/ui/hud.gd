extends CanvasLayer

var console_out_buffer := PackedStringArray()

@onready var console: VBoxContainer = $Control/Console
@onready var console_out: RichTextLabel = $Control/Console/Output
@onready var console_in: LineEdit = $Control/Console/Input

func _ready():
	$Control/HBoxContainer/Coins/Icon.play("default")
	Logger.message_logged.connect(_on_message_logged)

func _input(event):
	if event.is_action_pressed("ui_toggle_console"):
		console.visible = not console.visible

func _on_message_logged(message: String):
	console_out_buffer.append(message)
	console_out.text = "\n".join(console_out_buffer)
