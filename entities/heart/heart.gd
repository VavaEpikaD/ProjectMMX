extends Area2D

enum HeartType { SMALL, BIG }

@export var heart_type: HeartType = HeartType.SMALL
@export var heal_amount: int = 1
@export var lifetime: float = 7.0

var _time_alive: float = 0.0

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	apply_type(heart_type)
	if anim_sprite:
		anim_sprite.play("default")

func _process(delta: float) -> void:
	if lifetime <= 0.0:
		return
	_time_alive += delta
	if _time_alive >= lifetime:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("heal"):
		body.heal(heal_amount)
		queue_free()

func apply_type(t: HeartType) -> void:
	heart_type = t
	match t:
		HeartType.SMALL:
			heal_amount = 1
			scale = Vector2.ONE * 0.75
		HeartType.BIG:
			heal_amount = 3
			scale = Vector2.ONE * 1.25
