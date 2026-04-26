extends Node2D

@export var speed: float = 400.0
@export var lifetime: float = 2.0

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
