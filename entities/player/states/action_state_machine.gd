extends StateMachine
class_name ActionStateMachine

@export var charge_tier_1_time: float = 0.5 # Half a second for small charge
@export var charge_tier_2_time: float = 1.5 # 1.5 seconds for max charge

# Preload Palettes for rapid color flashing
var default_palette = preload("res://assets/palettes/default.png")
var charge1_palette = preload("res://assets/palettes/charge.png")
var charge2_palette = preload("res://assets/palettes/charge2.png")

const CHARGE_FLASH_INTERVAL: float = 0.05 # Color flashing swap speed (50ms)

# Charging variables
var charge_timer: float = 0.0
var shoot_anim_timer: float = 0.0
var is_charging: bool = false
var charge_level: int = 0
var charge_flash_timer: float = 0.0
var charge_palette_flag: bool = false

# Cached node references
@onready var sprite: Sprite2D = owner.get_node_or_null("Sprite2D") if owner else null
@onready var charge_anims: Node2D = owner.get_node_or_null("ChargeAnims") if owner else null

func _process(delta: float) -> void:
	if shoot_anim_timer > 0:
		shoot_anim_timer -= delta
	
	# 1. Capture Shoot Button Press
	if Input.is_action_just_pressed("shoot"):
		# Shoot base lemon projectile immediately on press
		determine_and_fire(0)
		is_charging = true
		charge_timer = 0.0
		charge_level = 0
		charge_flash_timer = 0.0
		charge_palette_flag = false

	# 2. Accumulate charge time while holding button
	if is_charging and Input.is_action_pressed("shoot"):
		charge_timer += delta
		
		# High-precision threshold checking
		if charge_timer >= charge_tier_2_time:
			if charge_level < 2:
				charge_level = 2
				if charge_anims:
					charge_anims.update_charge_level(2)
		elif charge_timer >= charge_tier_1_time:
			if charge_level < 1:
				charge_level = 1
				if charge_anims:
					charge_anims.update_charge_level(1)
					charge_anims.start_charging_effect()
		
		# Drive the rapid color palette flashing (Level 1 and Level 2)
		if charge_level > 0:
			charge_flash_timer += delta
			if charge_flash_timer >= CHARGE_FLASH_INTERVAL:
				charge_flash_timer -= CHARGE_FLASH_INTERVAL
				charge_palette_flag = !charge_palette_flag
				if charge_palette_flag:
					set_character_palette(default_palette)
				else:
					if charge_level == 1 or charge_level == 2:
						set_character_palette(charge1_palette)

	# 3. Capture Shoot Button Release
	if Input.is_action_just_released("shoot") and is_charging:
		# Unleash charged shot if we have accumulated charge
		if charge_level > 0:
			determine_and_fire(charge_level)
		
		# Reset all charge states and turn off visual effects
		is_charging = false
		charge_level = 0
		charge_timer = 0.0
		charge_flash_timer = 0.0
		if charge_anims:
			charge_anims.update_charge_level(0)
		
		# Reset player color to default palette
		set_character_palette(default_palette)

func determine_and_fire(forced_level: int = -1) -> void:
	shoot_anim_timer = 0.5
	
	# Determine firing level
	var level: int = forced_level
	if level == -1:
		if charge_timer >= charge_tier_2_time:
			level = 2
		elif charge_timer >= charge_tier_1_time:
			level = 1
		else:
			level = 0
		
	owner.shoot(level)

func is_shooting() -> bool:
	return shoot_anim_timer > 0

func set_character_palette(palette_tex: Texture2D) -> void:
	# Applies the color palette to the Sprite2D shader
	if sprite and sprite.material:
		sprite.material.set_shader_parameter("palette", palette_tex)
