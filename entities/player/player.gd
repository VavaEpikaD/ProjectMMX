extends CharacterBody2D

@onready var movement_sm = $MovementStateMachine
@onready var action_sm = $ActionStateMachine
@onready var anim_player = $AnimationPlayer

func _process(delta: float) -> void:
	update_animations()
	
func update_animations() -> void:
	var current_movement: String = movement_sm.current_state.name.to_lower()
	
	
	var is_shooting: bool = action_sm.is_shooting()
	var anim_to_play: String = current_movement
	if is_shooting:
		anim_to_play += "_shoot"
		
	if anim_player.current_animation != anim_to_play:
		anim_player.play(anim_to_play)
