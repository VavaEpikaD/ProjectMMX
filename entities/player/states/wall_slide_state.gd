extends State
class_name WallSlideState

@export var slide_speed: float = 75.0
@export var wall_jump_velocity: Vector2 = Vector2(250.0, -350.0)
@export var dash_wall_jump_velocity: Vector2 = Vector2(400.0, -350.0)
@export var wall_repel_force: float = 100.0

var wall_normal: Vector2

func enter() -> void:
	wall_normal = player.get_wall_normal()
	# This might need to change later
	player.get_node("Sprite2D").flip_h = wall_normal.x < 0

func physics_update(_delta: float) -> void:
	player.velocity.y = slide_speed
	
	# --- TRANSITIONS ---
	if player.is_on_floor():
		transitioned.emit(self, "idle")
		return
	
	var current_input: float = Input.get_axis("move_left", "move_right")
	if not player.is_on_wall() or current_input == wall_normal.x or current_input == 0:
		if current_input == 0:
			player.velocity.x = wall_repel_force * wall_normal.x
		transitioned.emit(self, "fall")
		return
	
	# --- Execute wall jump ---
	if Input.is_action_just_pressed("jump"):
		var kick_force: Vector2 = wall_jump_velocity
		
		if Input.is_action_pressed("dash"):
			kick_force = dash_wall_jump_velocity
			player.max_air_speed = kick_force.x
		else:
			player.max_air_speed = 150.0
		
		player.velocity.x = kick_force.x * wall_normal.x
		player.velocity.y = kick_force.y
		
		player.wall_jump_lockout_timer = 0.15
		
		transitioned.emit(self, "jump")
		
