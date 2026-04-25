extends Node
class_name State

# Signal to tell the state machine to switch states
signal transitioned(state: State, new_state: State)

var player: CharacterBody2D

# Called when entering new state
func enter() -> void:
	pass

# Called when exiting state
func exit () -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass
	
