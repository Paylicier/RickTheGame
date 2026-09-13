extends Area2D

signal activated
signal deactivated

@export var normal_texture: Texture2D
@export var pressed_texture: Texture2D

@export var press_sfx: AudioStream
@export var release_sfx: AudioStream

var body_on_it : Node2D

func play_sound(sound: AudioStream) -> void:
	$"../ButtonSFX".stream = sound
	$"../ButtonSFX".play()

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("interactable") and body_on_it == null:
		play_sound(press_sfx)
		$"../Sprite2D".texture = pressed_texture
		activated.emit()
		body_on_it = body

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("interactable") and body_on_it == body:
		play_sound(release_sfx)
		$"../Sprite2D".texture = normal_texture
		deactivated.emit()
		body_on_it = null
