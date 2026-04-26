extends StateMachine
class_name ActionStateMachine

func is_shooting() -> bool:
	return Input.is_action_pressed("shoot")
