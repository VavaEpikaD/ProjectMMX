extends StateMachine
class_name ActionStateMachine

@export var charge_tier_1_time: float = 0.5 # Half a second for small charge
@export var charge_tier_2_time: float = 1.5 # 1.5 seconds for max charge

var charge_timer: float = 0.0
var shoot_anim_timer: float = 0.0

func _process(delta: float) -> void:
	if shoot_anim_timer > 0:
		shoot_anim_timer -= delta
	
	if Input.is_action_pressed("shoot"):
		charge_timer += delta
		# Add visual effects here
		
	if Input.is_action_just_released("shoot"):
		determine_and_fire()
		charge_timer = 0.0
	elif Input.is_action_pressed("shoot") and charge_timer == 0:
		determine_and_fire()
	

func determine_and_fire() -> void:
	shoot_anim_timer = 0.5
	
	var level: int = 0
	if charge_timer >= charge_tier_2_time:
		level = 2
	elif charge_timer >= charge_tier_1_time:
		level = 1
		
	owner.shoot(level)

func is_shooting() -> bool:
	return shoot_anim_timer > 0
