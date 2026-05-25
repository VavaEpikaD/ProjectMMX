extends Node2D
class_name Lemon

@export var speed: float = 400.0
@export var lifetime: float = 5.0
@export var damage: int = 1
@export var level: int = 0

@onready var anim_sprite = $AnimatedSprite2D
var current_speed = speed if level == 0 else 50

var direction: Vector2 = Vector2.RIGHT
var _time_alive: float = 0.0

func _ready() -> void:
	add_to_group("player_bullet")
	anim_sprite.play("shoot_start")

func get_damage() -> int:
	return damage

func launch(dir: Vector2) -> void:
	direction = dir.normalized()
	
	if direction == Vector2.LEFT:
		rotation = PI
	else:
		rotation = 0

func _physics_process(delta: float) -> void:
	position += direction * current_speed * delta
	_time_alive += delta
	if _time_alive >= lifetime:
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_animated_sprite_2d_animation_finished() -> void:
	if anim_sprite.animation == "shoot_start":
		anim_sprite.play("shoot")
		current_speed = speed
