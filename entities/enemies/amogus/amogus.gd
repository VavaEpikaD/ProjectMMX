extends Area2D

@export var max_health: int = 3
@export var health: int = 3

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("enemy")
	health = clamp(health, 0, max_health)
	if anim_sprite:
		anim_sprite.play("default")

func take_damage(amount: int) -> void:
	if amount <= 0:
		return
	health = max(health - amount, 0)
	if health == 0:
		die()

func die() -> void:
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if not area.is_in_group("player_bullet"):
		return
	var damage = 1
	if area.has_method("get_damage"):
		damage = area.get_damage()
	take_damage(damage)
	area.queue_free()
