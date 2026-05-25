extends Area2D

@export var speed: float = 260.0
@export var damage: int = 0

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	add_to_group("player_bullet")
	add_to_group("special_weapon")
	if anim_sprite:
		anim_sprite.play("fire")

func get_damage() -> int:
	return damage

func launch(dir: Vector2) -> void:
	direction = dir.normalized()
	if anim_sprite:
		anim_sprite.flip_h = direction.x < 0.0

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
