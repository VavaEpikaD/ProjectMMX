extends Area2D
class_name Enemy3GravityBullet

@export var rise_speed: float = 220.0
@export var rise_time: float = 0.5
@export var gravity_accel: float = 900.0
@export var lifetime: float = 5.0
@export var damage: int = 1
@export var fall_texture: Texture2D

@onready var sprite: Sprite2D = $Sprite2D

var _time_alive: float = 0.0
var _velocity: Vector2 = Vector2.ZERO
var _rise_dir: Vector2 = Vector2.UP

func _ready() -> void:
	add_to_group("enemy_bullet")
	_velocity = _rise_dir * rise_speed
	if sprite:
		sprite.flip_h = (_rise_dir.x > 0)

func launch(dir: Vector2) -> void:
	if dir == Vector2.ZERO:
		dir = Vector2.UP
	_rise_dir = dir.normalized()
	_velocity = _rise_dir * rise_speed

func _physics_process(delta: float) -> void:
	_time_alive += delta
	if _time_alive <= rise_time:
		_velocity = _rise_dir * rise_speed
	else:
		if sprite and fall_texture and sprite.texture != fall_texture:
			sprite.texture = fall_texture
		_velocity.y += gravity_accel * delta
	position += _velocity * delta
	if _time_alive >= lifetime:
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
		return
	if body is TileMapLayer or body is TileMap or body is StaticBody2D:
		queue_free()
