extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var max_air_speed: float = 150.0
var wall_jump_lockout_timer: float = 0.0

@onready var movement_sm: StateMachine = $MovementStateMachine
@onready var action_sm: StateMachine = $ActionStateMachine
@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if movement_sm.current_state:
		movement_sm.current_state.physics_update(delta)
		
	if wall_jump_lockout_timer > 0:
		wall_jump_lockout_timer -= delta
		
	move_and_slide()
	update_animations()
	
func _process(delta: float) -> void:
	if movement_sm.current_state:
		movement_sm.update(delta)
	
func update_animations() -> void:
	var current_movement: String = movement_sm.current_state.name.to_lower()
	
	var is_shooting: bool = action_sm.is_shooting()
	var anim_to_play: String = current_movement.trim_suffix("state")
	if is_shooting:
		anim_to_play += "_shoot"
		
	if anim_player.current_animation != anim_to_play:
		anim_player.play(anim_to_play)
