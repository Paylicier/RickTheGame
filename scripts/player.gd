extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -300.0
const SNAP_SPEED = 20.0
const DUST_STEP_DISTANCE = 24.0

enum SoundType {
	STEP,
	JUMP,
	WALL_JUMP
}

@onready var visual: Node2D = $Sprite2D
@onready var col: Node2D = $CollisionShape2D
@onready var dust: GPUParticles2D = $DustParticles
@onready var audio_player: AudioStreamPlayer2D = $PlayerSFX


@export var cube_size: float = 32.0
@export var SFX: Array[AudioStream] = []
@export var push_force: float = 80.0

var _was_on_floor := false
var _was_on_wall := false
var _distance_since_dust := 0.0
var is_magic_in_the_air: float = 0.0;

var rng := RandomNumberGenerator.new()

var last_sound: SoundType

func play_sfx(type: SoundType) -> void:
	if type >= SFX.size() or SFX[type] == null:
		return
		
	if not audio_player.playing || last_sound != type:
		audio_player.stream = SFX[type]
		audio_player.play()
		last_sound = type

func _emit_dust() -> void:
	dust.restart()
	dust.emitting = true

func _play_footstep() -> void:
	play_sfx(SoundType.STEP)
	
func _play_wj() -> void:
	play_sfx(SoundType.WALL_JUMP)
	
func _play_jump() -> void:
	play_sfx(SoundType.JUMP)

func _physics_process(delta: float) -> void:
	
	var direction := Input.get_axis("left", "right")

	if position.y >= 800: # maybe using a trigger zone or whatever it's called would be better idk
		get_tree().reload_current_scene()
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		visual.rotation += direction * 6.0 * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		_play_jump()

	if Input.is_action_just_pressed("jump") and is_on_wall_only() and direction:
		velocity.y = JUMP_VELOCITY
		velocity.x = get_wall_normal().x*SPEED
		is_magic_in_the_air = true
		_play_wj()

	if not is_magic_in_the_air:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider is RigidBody2D:
			var push_direction = -collision.get_normal()
			collider.apply_central_impulse(push_direction * push_force)
	
	if is_on_floor() and not _was_on_floor:
		_emit_dust()

	if is_on_floor() and abs(velocity.x) > 1.0:
		_distance_since_dust += abs(velocity.x) * delta
		if _distance_since_dust >= DUST_STEP_DISTANCE:
			_distance_since_dust = 0.0
			_emit_dust()
	else:
		_distance_since_dust = 0.0

	if is_on_wall() and not _was_on_wall:
		dust.rotation = PI / 2.0 if get_wall_normal().x > 0 else -PI / 2.0
		_emit_dust()

	_was_on_floor = is_on_floor()
	_was_on_wall = is_on_wall()

	if is_on_floor():
		is_magic_in_the_air = false
		if abs(velocity.x) > 1.0:
			var radius := cube_size / 2.0
			visual.rotation += velocity.x * delta / radius
			_play_footstep()
		else:
			var target : float = round(visual.rotation / (PI / 2.0)) * (PI / 2.0)
			visual.rotation = lerp_angle(visual.rotation, target, SNAP_SPEED * delta)

	_update_pivot_offset()

func _update_pivot_offset() -> void:
	var r := cube_size / 2.0
	var delta_angle := fposmod(visual.rotation + PI / 4.0, PI / 2.0) - PI / 4.0
	var dist_to_bottom := r / cos(delta_angle)
	visual.position.y = col.position.y - (dist_to_bottom - r)
