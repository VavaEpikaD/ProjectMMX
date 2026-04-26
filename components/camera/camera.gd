extends Camera2D

@export_category("Targeting")
@export var target: Node2D

@export_category("Deadzone")
@export var deadzone_size: Vector2 = Vector2(60, 40)
@export var smoothing_speed: float = 8.0

@export_category("Look-Ahead")
@export var look_ahead_distance: float = 60.0
@export var look_ahead_time_threshold: float = 0.3
@export var look_ahead_smoothing_speed: float = 4.0

@export_category("Debug")
@export var show_debug_deadzone: bool = false

@export_category("Limits (Locking)")
@export var enable_camera_locks: bool = true
@export var limit_left_x: float = -10000.0
@export var limit_right_x: float = 10000.0
@export var limit_top_y: float = -10000.0
@export var limit_bottom_y: float = 100.0

var _current_look_ahead_offset: Vector2 = Vector2.ZERO
var _target_look_ahead_offset: Vector2 = Vector2.ZERO
var _time_moving_in_dir: float = 0.0
var _last_target_pos: Vector2 = Vector2.ZERO
var _last_moving_dir: int = 0

func _ready() -> void:
	# Detach from parent to move independently
	set_as_top_level(true)
	
	if target:
		global_position = target.global_position
		_last_target_pos = target.global_position

func _physics_process(delta: float) -> void:
	if not target:
		return
		
	var target_pos = target.global_position
	
	# Look-ahead logic
	var move_delta = target_pos - _last_target_pos
	var current_dir = 0
	
	if abs(move_delta.x) > 0.1:
		current_dir = sign(move_delta.x)
		
	if current_dir != 0 and current_dir == _last_moving_dir:
		_time_moving_in_dir += delta
	else:
		_time_moving_in_dir = 0.0
		
	_last_moving_dir = current_dir
	_last_target_pos = target_pos
	
	if _time_moving_in_dir >= look_ahead_time_threshold and current_dir != 0:
		_target_look_ahead_offset = Vector2(current_dir * look_ahead_distance, 0)
	elif current_dir == 0:
		_target_look_ahead_offset = Vector2.ZERO
		
	_current_look_ahead_offset = _current_look_ahead_offset.lerp(_target_look_ahead_offset, look_ahead_smoothing_speed * delta)
	
	# Deadzone and tracking
	var focus_point = target_pos + _current_look_ahead_offset
	var distance_to_focus = focus_point - global_position
	var desired_pos = global_position
	
	if abs(distance_to_focus.x) > deadzone_size.x / 2.0:
		desired_pos.x = focus_point.x - sign(distance_to_focus.x) * (deadzone_size.x / 2.0)
		
	if abs(distance_to_focus.y) > deadzone_size.y / 2.0:
		desired_pos.y = focus_point.y - sign(distance_to_focus.y) * (deadzone_size.y / 2.0)
		
	var next_pos = global_position.lerp(desired_pos, smoothing_speed * delta)
	
	# Camera locking/bounds
	if enable_camera_locks:
		next_pos.x = clamp(next_pos.x, limit_left_x, limit_right_x)
		next_pos.y = clamp(next_pos.y, limit_top_y, limit_bottom_y)
		
	global_position = next_pos
	
	if show_debug_deadzone:
		queue_redraw()

func _draw() -> void:
	if show_debug_deadzone:
		var rect = Rect2(-deadzone_size / 2.0, deadzone_size)
		draw_rect(rect, Color(1.0, 0.0, 0.0, 0.4), false, 2.0)
