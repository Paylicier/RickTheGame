extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -300.0
const SNAP_SPEED = 10.0

@onready var visual: Node2D = $Sprite2D
@onready var col: Node2D = $CollisionShape2D
@export var cube_size: float = 32.0

func _physics_process(delta: float) -> void:
	
	var direction := Input.get_axis("left", "right")
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		visual.rotation += direction * 6.0 * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	if is_on_floor():
		if abs(velocity.x) > 1.0:
			var radius := cube_size / 2.0
			visual.rotation += velocity.x * delta / radius
		else:
			var target : float = round(visual.rotation / (PI / 2.0)) * (PI / 2.0)
			visual.rotation = lerp_angle(visual.rotation, target, SNAP_SPEED * delta)

	_update_pivot_offset()

func _update_pivot_offset() -> void:
	var r := cube_size / 2.0
	var delta_angle := fposmod(visual.rotation + PI / 4.0, PI / 2.0) - PI / 4.0
	var dist_to_bottom := r / cos(delta_angle)
	visual.position.y = col.position.y - (dist_to_bottom - r)
