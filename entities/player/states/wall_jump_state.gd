extends State

class_name WallJumpState
func enter() -> void:
	# Don't set velocity.y here, because WallSlideState already did!
	player.consume_jump()
func physics_update(_delta: float) -> void:
	# Same fall logic as JumpState
	if player.velocity.y >= 0:
		transitioned.emit(self, "fall")
		return
	
	var dir: float = Input.get_axis("move_left", "move_right")
	if player.wall_jump_lockout_timer <= 0:
		if dir != 0:
			player.get_node("Sprite2D").flip_h = dir < 0
			player.update_muzzle()
			
			player.velocity.x = dir * player.max_air_speed
		else:
			player.velocity.x = 0
		
	if player.is_on_wall_only() and player.velocity.y > 0:
		var wall_dir: float = -player.get_wall_normal().x
		if dir == wall_dir:
			transitioned.emit(self, "wallslide")
			return
