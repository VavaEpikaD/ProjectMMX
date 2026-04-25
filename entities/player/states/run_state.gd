# Example state
extends State
class_name RunState

@export var speed: float = 150.0

func enter() -> void:
	# Animation logic may also be handled here
	pass
	
func physics_update(_delta: float) -> void:
	var dir = Input.get_axis("move_left", "move_right")
	
	if dir:
		player.velocity.x = dir * speed
		player.get_node("Sprite2D").flip_h = dir < 0
	else:
		transitioned.emit(self, "idle")
		return
		
	if Input.is_action_just_pressed("jump"):
		transitioned.emit(self, "jump")
		return
		
	if Input.is_action_just_pressed("dash"):
		transitioned.emit(self, "dash")
		return
	
	player.move_and_slide()
