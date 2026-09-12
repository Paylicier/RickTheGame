extends Button

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		get_tree().change_scene_to_file("res://main.tscn")
