extends Area2D

@export var heal_amount: int = 1

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	if anim_sprite:
		anim_sprite.play("default")

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("heal"):
		body.heal(heal_amount)
		queue_free()
