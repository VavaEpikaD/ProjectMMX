extends State
class_name FallState

@export var base_run_speed: float = 150.0

func physics_update(_delta: float) -> void:
	var dir: float = Input.get_axis("move_left", "move_right")

	if player.is_on_floor():
		if dir != 0:
			transitioned.emit(self, "run")
		else:
			transitioned.emit(self, "idle")
		return
	
	if dir != 0:
		player.get_node("Sprite2D").flip_h = dir < 0

		player.velocity.x = dir * player.max_air_speed
	else:
		player.velocity.x = 0
