extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var max_air_speed: float = 150.0

# Timers
var wall_jump_lockout_timer: float = 0.0
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

var bullet_scene: PackedScene = preload("res://entities/bullet/bullet.tscn")

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

	if Input.is_action_just_pressed("shoot"):
		shoot()
	
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

func shoot() -> void:
	var bullets = get_tree().get_nodes_in_group("player_bullet")
	if bullets.size() >= 3:
		return

	var b = bullet_scene.instantiate()
	# spawn at muzzle position if available, otherwise at player position
	var muzzle = get_node_or_null("Muzzle")
	if not muzzle:
		muzzle = find_child("Muzzle", true, false)
	if muzzle:
		b.global_position = muzzle.global_position
	else:
		b.global_position = global_position
	var facing_right: bool = not get_node("Sprite2D").flip_h
	var dir: Vector2 = Vector2.RIGHT if facing_right else Vector2.LEFT
	if b.has_method("launch"):
		b.launch(dir)
	# add to the active scene root so bullets persist
	var root_scene = get_tree().current_scene
	if root_scene:
		root_scene.add_child(b)
	else:
		get_tree().get_root().add_child(b)