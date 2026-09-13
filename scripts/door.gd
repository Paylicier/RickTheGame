extends StaticBody2D

@export var open_distance: float = 64.0
@export var open_duration: float = 0.5

@export var trigger_node: Node
@export var open_signal_name: String = "activated"
@export var stay_opened: bool = false
@export var close_signal_name: String = "deactivated"

var opened: bool = false
var tween: Tween
var closed_position_y: float

func _ready() -> void:
	closed_position_y = position.y

	if not trigger_node:
		return

	if trigger_node.has_signal(open_signal_name):
		trigger_node.connect(open_signal_name, Callable(self, "_on_open"))

	if not stay_opened and trigger_node.has_signal(close_signal_name):
		trigger_node.connect(close_signal_name, Callable(self, "_on_close"))


func _on_open() -> void:
	if opened:
		return
	opened = true

	_animate_to_y(closed_position_y - open_distance)


func _on_close() -> void:
	if not opened or stay_opened:
		return
	opened = false

	_animate_to_y(closed_position_y)


func _animate_to_y(target_y: float) -> void:
	if tween and tween.is_running():
		tween.kill()

	tween = create_tween()
	tween.tween_property(self, "position:y", target_y, open_duration)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
