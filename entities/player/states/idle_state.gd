extends State
class_name IdleState

func enter() -> void:
	player.max_air_speed = 150.0
	pass

	
func physics_update(_delta: float) -> void:
	var dir: float = Input.get_axis("move_left", "move_right")
	
	player.velocity.x = 0
	player.velocity.y = 0
	
	if dir:
		transitioned.emit(self, "run")
		return
	
	if Input.is_action_just_pressed("jump"):
		transitioned.emit(self, "jump")
		return
		
	if Input.is_action_just_pressed("dash"):
		transitioned.emit(self, "dash")
		return
