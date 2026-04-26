extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var max_air_speed: float = 150.0

# Timers
var wall_jump_lockout_timer: float = 0.0
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

var lemon_scene: PackedScene = preload("res://entities/projectiles/buster/lemon.tscn")
var charge_1_scene = preload("res://entities/projectiles/buster/level1_charge.tscn")
var charge_2_scene = preload("res://entities/projectiles/buster/level2_charge.tscn")

@export var fall_gravity_multiplier: float = 1.5 # Makes falling feel faster/heavier
@export var short_hop_gravity_multiplier: float = 3.0 # Yanks the player down if they release jump
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.1

@onready var movement_sm: StateMachine = $MovementStateMachine
@onready var action_sm: StateMachine = $ActionStateMachine
@onready var anim_player: AnimationPlayer = $AnimationPlayer

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

	if not is_on_floor():
		var applied_gravity: float = gravity
		if velocity.y < 0 and not Input.is_action_pressed("jump"):
			applied_gravity *= short_hop_gravity_multiplier
		elif velocity.y > 0:
			applied_gravity *= fall_gravity_multiplier
		velocity.y += applied_gravity * delta
		
	if movement_sm.current_state:
		movement_sm.current_state.physics_update(delta)
		
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
		# anim_to_play += "_shoot"
		pass
		
	if anim_player.current_animation != anim_to_play:
		anim_player.play(anim_to_play)

func consume_jump() -> void:
	jump_buffer_timer = 0.0
	coyote_timer = 0.0

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
	b.global_position = muzzle.global_position
	
	var facing_right: bool = not get_node("Sprite2D").flip_h
	var dir: Vector2 = Vector2.RIGHT if facing_right else Vector2.LEFT
	
	b.launch(dir)
	# add to the active scene root so bullets persist
	var root_scene = get_tree().current_scene
	if root_scene:
		root_scene.add_child(b)
	else:
		get_tree().get_root().add_child(b)
