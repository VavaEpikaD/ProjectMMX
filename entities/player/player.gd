extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var max_air_speed: float = 150.0
var terminal_velocity: float = -400

# Timers
var wall_jump_lockout_timer: float = 0.0
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var invincibility_timer: float = 0.0

var lemon_scene: PackedScene = preload("res://entities/projectiles/buster/lemon.tscn")
var charge_1_scene = preload("res://entities/projectiles/buster/level1_charge.tscn")
var charge_2_scene = preload("res://entities/projectiles/buster/level2_charge.tscn")

@export var fall_gravity_multiplier: float = 1.0 # Makes falling feel faster/heavier
@export var short_hop_gravity_multiplier: float = 3.5 # Yanks the player down if they release jump
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.1
@export var max_health: int = 16
@export var health: int = 16
@export var max_weapon_energy: int = 30
@export var weapon_energy: int = 30
@export var wall_slide_shoot_orientation_delay: bool = false
@export var invincibility_duration: float = 1.0

@onready var movement_sm: StateMachine = $MovementStateMachine
@onready var action_sm: StateMachine = $ActionStateMachine
@onready var anim_player: AnimationPlayer = $AnimationPlayer

# Blinking Variables
var blink_timer: float = 0.0
var blink_base_time: float = 0.05 # Determines how fast the player blinks

signal health_changed(current_hp: int)
signal max_health_changed(max_hp: int)

func _ready() -> void:
	add_to_group("player")
	health = clamp(health, 0, max_health)
	weapon_energy = clamp(weapon_energy, 0, max_weapon_energy)
	
	health_changed.emit(health)
	max_health_changed.emit(max_health)

func update_muzzle() -> void:
	$Muzzle.position.x = -abs($Muzzle.position.x) if $Sprite2D.flip_h else abs($Muzzle.position.x)

func _hanle_jump_timers(delta: float) -> void:
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta
		
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta
		
	if wall_jump_lockout_timer > 0:
		wall_jump_lockout_timer -= delta

func _physics_process(delta: float) -> void:
	_hanle_jump_timers(delta)
	
	if invincibility_timer > 0.0:
		invincibility_timer = max(invincibility_timer - delta, 0.0)

	if not is_on_floor():
		var applied_gravity: float = gravity
		if velocity.y < 0 and not Input.is_action_pressed("jump"):
			applied_gravity *= short_hop_gravity_multiplier
		elif velocity.y > 0:
			applied_gravity *= fall_gravity_multiplier
		velocity.y += applied_gravity * delta
		
		velocity.y = max(velocity.y, terminal_velocity)
		
	if movement_sm.current_state:
		movement_sm.current_state.physics_update(delta)
	
	move_and_slide()
	update_animations()
	
func _process(delta: float) -> void:
	if movement_sm.current_state:
		movement_sm.update(delta)
		
	# Handle Invincibility Blinking
	if invincibility_timer > 0.0:
		blink_timer -= delta
		if blink_timer <= 0.0:
			$Sprite2D.visible = not $Sprite2D.visible
			blink_timer = blink_base_time
	else:
		# Ensure the sprite is visible when invincibility ends
		if not $Sprite2D.visible:
			$Sprite2D.visible = true
		
func update_animations() -> void:
	var current_movement: String = movement_sm.current_state.name.to_lower()

	var is_shooting: bool = action_sm.is_shooting()
	var anim_to_play: String = current_movement.trim_suffix("state")

	if is_shooting:
		anim_to_play += "_shoot"

	if anim_player.current_animation != anim_to_play:
		var previous_anim: String = anim_player.current_animation
		var current_time: float = anim_player.current_animation_position
		
		anim_player.play(anim_to_play)
		
		if previous_anim != "":
			var old_base: String = previous_anim.replace("_shoot", "")
			var new_base: String = anim_to_play.replace("_shoot", "")
			
			if old_base == new_base:
				anim_player.seek(current_time, true)

func consume_jump() -> void:
	jump_buffer_timer = 0.0
	coyote_timer = 0.0

func take_damage(amount: int) -> void:
	if amount <= 0:
		return
	if invincibility_timer > 0.0:
		return
		
	health = clamp(health - amount, 0, max_health)
	print("Player took damage: ", amount, " health: ", health, "/", max_health)
	
	# Trigger invincibility and first blink
	invincibility_timer = invincibility_duration
	blink_timer = blink_base_time
	$Sprite2D.visible = false
	
	health_changed.emit(health)
	
	if health == 0:
		queue_free()

func add_health(amount: int) -> void:
	if amount <= 0:
		return
	health = clamp(health + amount, 0, max_health)
	health_changed.emit(health)

func add_weapon_energy(amount: int) -> void:
	if amount <= 0:
		return
	weapon_energy = clamp(weapon_energy + amount, 0, max_weapon_energy)
	

func shoot(charge_level: int) -> void:
	var bullets = get_tree().get_nodes_in_group("player_bullet")
	if charge_level == 0 and bullets.size() >= 3:
		return

	var bullet_to_spawn: PackedScene
	match charge_level:
		2: bullet_to_spawn = charge_2_scene
		1: bullet_to_spawn = charge_1_scene
		0: bullet_to_spawn = lemon_scene
		
	var b = bullet_to_spawn.instantiate()
		
	# spawn at muzzle position if available, otherwise at player position
	var muzzle = get_node_or_null("Muzzle")
	update_muzzle()
	
	var facing_right: bool = not get_node("Sprite2D").flip_h
	
	if movement_sm.current_state.name == "WallSlideState" and not wall_slide_shoot_orientation_delay:
		facing_right = not facing_right
		$Muzzle.position.x *= -1
		
	b.global_position = muzzle.global_position
	
	var dir: Vector2 = Vector2.RIGHT if facing_right else Vector2.LEFT
	
	b.launch(dir)
	# add to the active scene root so bullets persist
	var root_scene = get_tree().current_scene
	if root_scene:
		root_scene.add_child(b)
	else:
		get_tree().get_root().add_child(b)
