extends Node

signal message_logged(message: String)

func append(message: String):
	emit_signal("message_logged", message)
	print(message)