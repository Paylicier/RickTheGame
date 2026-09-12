extends Button

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		text = "not available yet"
