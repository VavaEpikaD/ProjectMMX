extends Node2D

@export var speed: float = 400.0
@export var lifetime: float = 5.0

var direction: Vector2 = Vector2.RIGHT
var _time_alive: float = 0.0

func _ready() -> void:
	add_to_group("player_bullet")

func launch(dir: Vector2) -> void:
	direction = dir.normalized()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	_time_alive += delta
	if _time_alive >= lifetime:
		queue_free()

	# Despawn when leaving the visible viewport (works with a Camera2D following the player)
	var viewport = get_viewport()
	var cam: Camera2D = viewport.get_camera_2d()

	var screen_size: Vector2 = viewport.get_visible_rect().size
	# Compute half-size in world units accounting for camera zoom
	var half_size: Vector2 = Vector2(screen_size.x * 0.5 * cam.zoom.x, screen_size.y * 0.5 * cam.zoom.y)
	var top_left: Vector2 = cam.global_position - half_size
	var bottom_right: Vector2 = cam.global_position + half_size
	var cam_rect = Rect2(top_left, bottom_right - top_left)
	if not cam_rect.has_point(global_position):
		queue_free()
