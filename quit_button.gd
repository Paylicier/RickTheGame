extends Button

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		get_tree().quit(0)
