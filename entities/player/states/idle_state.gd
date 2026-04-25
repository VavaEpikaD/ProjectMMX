extends State


func enter() -> void:
	# Animation logic may also be handled here
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	var dir = Input.get_axis("move_left", "move_right")
	
	if dir:
		transitioned.emit(self, "run")
		return
	
	if Input.is_action_just_pressed("jump"):
		transitioned.emit(self, "jump")
		return
		
	if Input.is_action_just_pressed("dash"):
		transitioned.emit(self, "dash")
		return
