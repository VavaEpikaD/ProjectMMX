# Example state
extends State
class_name RunState

@export var speed: float = 150.0

func enter() -> void:
	player.max_air_speed = 150.0
	pass
	
func physics_update(_delta: float) -> void:
	var dir: float = Input.get_axis("move_left", "move_right")
		
	if player.jump_buffer_timer > 0 and player.is_on_floor():
		player.consume_jump()
		transitioned.emit(self, "jump")
		return
		
	if not player.is_on_floor():
		transitioned.emit(self, "fall")
		return
		
	if Input.is_action_just_pressed("dash"):
		transitioned.emit(self, "dash")
		return
		
	if dir == 0:
		transitioned.emit(self, "idle")
		return
	
	player.velocity.x = dir * speed
	player.get_node("Sprite2D").flip_h = dir < 0
	player.update_muzzle()
