extends Area2D

enum EnergyType { SMALL, BIG }

@export var energy_type: EnergyType = EnergyType.SMALL
@export var energy_amount: int = 1
@export var lifetime: float = 7.0

var _time_alive: float = 0.0

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	apply_type(energy_type)
	if anim_sprite:
		anim_sprite.play("default")

func _process(delta: float) -> void:
	if lifetime <= 0.0:
		return
	_time_alive += delta
	if _time_alive >= lifetime:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("add_energy"):
		body.add_energy(energy_amount)
		queue_free()

func apply_type(t: EnergyType) -> void:
	energy_type = t
	match t:
		EnergyType.SMALL:
			energy_amount = 1
			scale = Vector2.ONE * 0.8
		EnergyType.BIG:
			energy_amount = 3
			scale = Vector2.ONE * 1.2
