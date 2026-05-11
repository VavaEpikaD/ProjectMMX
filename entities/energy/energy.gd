extends Area2D

@export var energy_amount: int = 1

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("add_energy"):
		body.add_energy(energy_amount)
		queue_free()
