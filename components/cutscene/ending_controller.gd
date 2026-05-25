extends Node2D

@export var player_path: NodePath = NodePath("../Player")
@export var lock_duration: float = 1.0
@export var walk_distance: float = 40.0
@export var walk_duration: float = 3.0
@export var walk_direction: Vector2 = Vector2.RIGHT
@export var camera_path: NodePath = NodePath("../Camera")
@export var camera_center: Vector2 = Vector2(1335, 183)
@export var camera_center_duration: float = 0.5
@export var teleport_duration: float = 0.6
@export var pre_teleport_pause: float = 0.5
@export var black_fade_duration: float = 0.6
@export var black_hold_duration: float = 1.5
@export var end_text_delay: float = 0.3
@export var end_text: String = "GAME END"
@export var teleport_anim_name: String = "teleport"
@export var run_anim_name: String = "run"
@export var force_run_on_trigger: bool = true
@export var use_player_animation: bool = false

@onready var trigger: Area2D = $EndTrigger
@onready var target: Node2D = $EndTeleportTarget
@onready var fade_rect: ColorRect = $EndUI/FadeRect
@onready var end_label: Label = $EndUI/EndLabel
@onready var camera: Camera2D = get_node_or_null(camera_path) as Camera2D

var _running: bool = false
var _player: CharacterBody2D
var _player_sprite: Sprite2D
var _player_anim: AnimationPlayer

func _ready() -> void:
	_setup_ui()
	if trigger:
		trigger.monitoring = true
		trigger.collision_layer = 0
		trigger.collision_mask = 2
		trigger.body_entered.connect(_on_trigger_body_entered)

func _on_trigger_body_entered(body: Node) -> void:
	if _running:
		return
	if not body.is_in_group("player"):
		return
	_running = true
	_player = body as CharacterBody2D
	_player_sprite = body.get_node_or_null("Sprite2D") as Sprite2D
	_player_anim = body.get_node_or_null("AnimationPlayer") as AnimationPlayer
	if force_run_on_trigger:
		_force_run_animation()
	if trigger:
		trigger.monitoring = false
	_start_sequence()

func _start_sequence() -> void:
	_lock_player(true)
	await get_tree().create_timer(lock_duration).timeout
	await _center_camera()
	await _auto_walk()
	_stop_player_animation()
	if pre_teleport_pause > 0.0:
		await get_tree().create_timer(pre_teleport_pause).timeout
	await _play_teleport()
	_teleport_player()
	await _fade_to_black()
	await get_tree().create_timer(black_hold_duration).timeout
	if end_text_delay > 0.0:
		await get_tree().create_timer(end_text_delay).timeout
	_show_end_text()

func _lock_player(locked: bool) -> void:
	if not _player:
		return
	if locked:
		_player.velocity = Vector2.ZERO
		_player.set_physics_process(false)
		_player.set_process(false)

func _play_teleport() -> void:
	if use_player_animation and _player_anim and _player_anim.has_animation(teleport_anim_name):
		_player_anim.play(teleport_anim_name)
		await _player_anim.animation_finished
		return
	if _player_sprite:
		var tween = create_tween()
		tween.tween_property(_player_sprite, "modulate:a", 0.0, teleport_duration)
		tween.parallel().tween_property(_player_sprite, "scale", _player_sprite.scale * 0.1, teleport_duration)
		await tween.finished
	elif _player:
		_player.visible = false

func _force_run_animation() -> void:
	if _player_anim and _player_anim.has_animation(run_anim_name):
		_player_anim.play(run_anim_name)

func _stop_player_animation() -> void:
	if _player_anim and _player_anim.is_playing():
		_player_anim.stop()
	if _player:
		_player.velocity = Vector2.ZERO

func _auto_walk() -> void:
	if not _player:
		return
	if walk_duration <= 0.0 or walk_distance <= 0.0:
		return
	if walk_direction == Vector2.ZERO:
		return
	var dir = walk_direction.normalized()
	var speed = walk_distance / max(walk_duration, 0.001)
	var elapsed := 0.0
	while elapsed < walk_duration:
		await get_tree().physics_frame
		var delta = 1.0 / max(Engine.physics_ticks_per_second, 1)
		elapsed += delta
		_apply_forced_walk(dir, speed, delta)
	_player.velocity = Vector2.ZERO

func _apply_forced_walk(dir: Vector2, speed: float, delta: float) -> void:
	if not _player:
		return
	var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	var vel = _player.velocity
	vel.x = dir.x * speed
	vel.y += gravity * delta
	_player.velocity = vel
	_player.move_and_slide()

func _center_camera() -> void:
	if not camera:
		return
	if "target" in camera:
		camera.target = null
	if camera_center_duration <= 0.0:
		camera.global_position = camera_center
		return
	var tween = create_tween()
	tween.tween_property(camera, "global_position", camera_center, camera_center_duration)
	await tween.finished

func _teleport_player() -> void:
	if _player and target:
		_player.global_position = target.global_position

func _fade_to_black() -> void:
	if not fade_rect:
		return
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, black_fade_duration)
	await tween.finished

func _show_end_text() -> void:
	if end_label:
		end_label.visible = true

func _setup_ui() -> void:
	if fade_rect:
		fade_rect.color = Color(0, 0, 0, 1)
		fade_rect.modulate.a = 0.0
		fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		fade_rect.offset_left = 0.0
		fade_rect.offset_top = 0.0
		fade_rect.offset_right = 0.0
		fade_rect.offset_bottom = 0.0
	if end_label:
		end_label.text = end_text
		end_label.visible = false
		end_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		end_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		end_label.set_anchors_preset(Control.PRESET_CENTER)
		end_label.offset_left = -200
		end_label.offset_right = 200
		end_label.offset_top = -20
		end_label.offset_bottom = 20
