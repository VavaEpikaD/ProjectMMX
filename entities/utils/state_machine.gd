extends Node
class_name StateMachine

@export var initial_state: State

var current_state: State
var states: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transitioned.connect(on_state_transitioned)
			# Give the state a reference to the main player node
			child.player = owner
	
	if initial_state:
		initial_state.enter()
		current_state = initial_state

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)
		
func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)
		
func on_state_transitioned(state: State, new_state_name: String) -> void:
	if state != current_state:
		return
	
	var new_state: State = states.get(new_state_name.to_lower())
	if !new_state:
		push_warning("State does not exist: ", new_state_name)
		return
		
	if current_state:
		current_state.exit()
	
	new_state.enter()
	current_state = new_state
