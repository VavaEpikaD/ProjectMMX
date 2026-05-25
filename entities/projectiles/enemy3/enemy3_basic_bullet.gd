extends Area2D
class_name Enemy3BasicBullet

@export var speed: float = 450.0
@export var lifetime: float = 5.0
@export var damage: int = 1

var direction: Vector2 = Vector2.DOWN
var _time_alive: float = 0.0

func _ready() -> void:
	add_to_group("enemy_bullet")
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		sprite.flip_h = (direction.x > 0)

func launch(dir: Vector2) -> void:
	direction = dir.normalized()
	if direction == Vector2.ZERO:
		direction = Vector2.DOWN
	rotation = 0.0

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	_time_alive += delta
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
