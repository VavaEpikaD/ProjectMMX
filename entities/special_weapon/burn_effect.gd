extends Node2D

@export var base_size: Vector2 = Vector2(16, 16)
@export var damage_per_tick: float = 0.25
@export var tick_interval: float = 0.25
@export var duration: float = 4.0
@export var y_scale_multiplier: float = 1.5

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

var _target: Node = null
var _time_left: float = 0.0
var _tick_timer: float = 0.0
var _tick_interval: float = 0.25
var _damage_accum: float = 0.0

func _ready() -> void:
	z_index = 10
	if anim_sprite:
		anim_sprite.play("burn")
		_update_base_size()
	set_process(false)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if not _target or not is_instance_valid(_target):
		queue_free()
		return
	_time_left -= delta
	_tick_timer -= delta
	while _tick_timer <= 0.0 and _time_left > 0.0:
		_tick_timer += _tick_interval
		_damage_accum += damage_per_tick
		var whole_damage := int(floor(_damage_accum))
		if whole_damage > 0 and _target.has_method("take_damage"):
			_target.take_damage(whole_damage)
			_damage_accum -= whole_damage
	if _time_left <= 0.0:
		queue_free()

func start(target: Node, target_size: Vector2) -> void:
	if duration <= 0.0:
		queue_free()
		return
	_target = target
	_tick_interval = max(tick_interval, 0.05)
	_time_left = duration
	_tick_timer = _tick_interval
	_damage_accum = 0.0
	set_target_size(target_size)
	scale.y *= y_scale_multiplier
	set_process(true)

func set_target_size(target_size: Vector2) -> void:
	if base_size.x <= 0.0 or base_size.y <= 0.0:
		return
	var scale_x = target_size.x / base_size.x * 1.5
	var scale_y = target_size.y / base_size.y * 1.5
	scale = Vector2(max(scale_x, 0.1), max(scale_y, 0.1))

func _update_base_size() -> void:
	if not anim_sprite or not anim_sprite.sprite_frames:
		return
	var frames = anim_sprite.sprite_frames
	if not frames.has_animation("burn"):
		return
	if frames.get_frame_count("burn") == 0:
		return
	var tex = frames.get_frame_texture("burn", 0)
	if tex:
		base_size = tex.get_size()

func _on_animated_sprite_2d_animation_finished() -> void:
	if _time_left > 0.0:
		if anim_sprite:
			anim_sprite.play("burn")
		return
	queue_free()
