extends Camera2D

@export_category("Targeting")
@export var target: Node2D

@export_category("Deadzone")
## Dimensiunea ferestrei in care jucatorul se poate misca fara a misca camera
@export var deadzone_size: Vector2 = Vector2(60, 40)
@export var smoothing_speed: float = 8.0

@export_category("Look-Ahead")
@export var look_ahead_distance: float = 60.0
@export var look_ahead_time_threshold: float = 0.3
@export var look_ahead_smoothing_speed: float = 4.0

@export_category("Debug")
## Daca este bifat, va desena un dreptunghi rosu reprezentand zona moarta (doar pentru vizualizare)
@export var show_debug_deadzone: bool = false

@export_category("Limits (Locking)")
## Daca este activata, centrul camerei nu va putea depasi coordonatele de mai jos
@export var enable_camera_locks: bool = true
@export var limit_left_x: float = -10000.0
@export var limit_right_x: float = 10000.0
@export var limit_top_y: float = -10000.0
## Spre exemplu: Ground level sub care camera sa nu treaca
@export var limit_bottom_y: float = 100.0

var _current_look_ahead_offset: Vector2 = Vector2.ZERO
var _target_look_ahead_offset: Vector2 = Vector2.ZERO
var _time_moving_in_dir: float = 0.0
var _last_target_pos: Vector2 = Vector2.ZERO
var _last_moving_dir: int = 0

func _ready() -> void:
	# Face ca aceasta camera sa isi ignore parintele din punct de vedere al pozitiei.
	# Astfel poate fi controlata independent in timp ce este atasata jucatorului.
	set_as_top_level(true)
	
	if target:
		global_position = target.global_position
		_last_target_pos = target.global_position

func _physics_process(delta: float) -> void:
	if not target:
		return
		
	var target_pos = target.global_position
	
	# ==========================================
	# 1. Anticiparea Directiei (Look-Ahead / Lead)
	# ==========================================
	var move_delta = target_pos - _last_target_pos
	var current_dir = 0
	
	# Verificam daca personajul se misca semnificativ pe axa X
	if abs(move_delta.x) > 0.1:
		current_dir = sign(move_delta.x)
		
	if current_dir != 0 and current_dir == _last_moving_dir:
		_time_moving_in_dir += delta
	else:
		_time_moving_in_dir = 0.0
		
	_last_moving_dir = current_dir
	_last_target_pos = target_pos
	
	# Daca personajul s-a miscat constant intr-o directie peste timpul prag (X secunde)
	if _time_moving_in_dir >= look_ahead_time_threshold and current_dir != 0:
		_target_look_ahead_offset = Vector2(current_dir * look_ahead_distance, 0)
	elif current_dir == 0:
		# La oprire, focus-ul revine fluid in centru
		_target_look_ahead_offset = Vector2.ZERO
		
	# Aplicam o interpolare fluida offset-ului tinta
	_current_look_ahead_offset = _current_look_ahead_offset.lerp(_target_look_ahead_offset, look_ahead_smoothing_speed * delta)
	
	# ==========================================
	# 2. Urmarirea de Baza si "Zona Moarta"
	# ==========================================
	# Punctul spre care trebuie sa se deplaseze camera
	var focus_point = target_pos + _current_look_ahead_offset
	var distance_to_focus = focus_point - global_position
	var desired_pos = global_position
	
	# Deadzone: miscam desired_pos doar daca distanta e mai mare de jumatate din dimensiune
	if abs(distance_to_focus.x) > deadzone_size.x / 2.0:
		desired_pos.x = focus_point.x - sign(distance_to_focus.x) * (deadzone_size.x / 2.0)
		
	if abs(distance_to_focus.y) > deadzone_size.y / 2.0:
		desired_pos.y = focus_point.y - sign(distance_to_focus.y) * (deadzone_size.y / 2.0)
		
	# Smooth Damping: Interpolare fluida a camerei catre pozitia dorita
	var next_pos = global_position.lerp(desired_pos, smoothing_speed * delta)
	
	# ==========================================
	# 3. Limitele Nivelului (Camera Locking)
	# ==========================================
	if enable_camera_locks:
		next_pos.x = clamp(next_pos.x, limit_left_x, limit_right_x)
		next_pos.y = clamp(next_pos.y, limit_top_y, limit_bottom_y)
		
	global_position = next_pos
	
	# Cerem redesenarea pentru debug daca e activat
	if show_debug_deadzone:
		queue_redraw()

func _draw() -> void:
	if show_debug_deadzone:
		# Desenam un dreptunghi rosu centrat in jurul camerei pentru a vizualiza zona moarta
		var rect = Rect2(-deadzone_size / 2.0, deadzone_size)
		draw_rect(rect, Color(1.0, 0.0, 0.0, 0.4), false, 2.0)
