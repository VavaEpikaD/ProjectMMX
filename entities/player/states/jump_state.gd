extends State
class_name JumpState

@export var jump_velocity: float = -400.0
@export var base_run_speed: float = 150.0

func enter() -> void:
	player.velocity.y = jump_velocity
	
func physics_update(_delta: float) -> void:
	# When releasing the button mid jump, create shorter hop
	if Input.is_action_just_released("jump") and player.velocity.y < 0:
		player.velocity.y *= 0.5
	
	# Are we falling?
	if player.velocity.y >= 0:
		transitioned.emit(self, "fall")
		return
		
	var dir: float = Input.get_axis("move_left", "move_right")
	if player.wall_jump_lockout_timer <= 0:
		if dir != 0:
			player.get_node("Sprite2D").flip_h = dir < 0
			
			player.velocity.x = dir * player.max_air_speed
		else:
			player.velocity.x = 0
		
	if player.is_on_wall_only() and player.velocity.y > 0:
		var wall_dir: float = -player.get_wall_normal().x
		if dir == wall_dir:
			transitioned.emit(self, "wallslide")
			return
		
