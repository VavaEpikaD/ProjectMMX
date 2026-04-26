extends State
class_name DashState

@export var dash_speed: float = 350.0
@export var dash_duration: float = 0.4

var dash_timer: float = 0.0
var dash_dir: float = 0.0


func enter() -> void:
	dash_timer = dash_duration
	
	dash_dir = Input.get_axis("move_left", "move_right")
	if dash_dir == 0:
		dash_dir = -1.0 if player.get_node("Sprite2D").flip_h else 1.0

func physics_update(delta: float) -> void:
	dash_timer -= delta
	# Dash has fully ended on its own
	player.velocity.x = dash_dir * dash_speed
	if dash_timer <= 0:
		var current_input: float = Input.get_axis("move_left", "move_right")
		if current_input != 0:
			transitioned.emit(self, "run")
		else:
			transitioned.emit(self, "idle")
		return
		
	# --- Cancelation Checks ---
	if player.jump_buffer_timer > 0:
		if player.is_on_floor() or player.coyote_timer > 0:
			player.consume_jump()
			player.max_air_speed = dash_speed
			transitioned.emit(self, "jump")
			return
	
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		player.max_air_speed = dash_speed
		transitioned.emit(self, "jump")
		return
		
	if not player.is_on_floor():
		player.max_air_speed = dash_speed
		transitioned.emit(self, "fall")
		return
		
	var current_dir: float = Input.get_axis("move_left", "move_right")
	if current_dir != 0 and current_dir != dash_dir:
		transitioned.emit(self, "run")
		return
