extends StaticBody2D

var opened: bool = false
@export var open_distance: float = 64.0
@export var open_duration: float = 0.5

func _on_button_activated() -> void:
	if opened:
		return
	opened = true
	
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - open_distance, open_duration)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
