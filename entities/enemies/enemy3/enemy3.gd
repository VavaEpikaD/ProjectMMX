@tool
extends Area2D

@export var max_health: int = 3
@export var health: int = 3
@export var facing_right: bool = false
@export var shoot_offset: Vector2 = Vector2.ZERO
@export var normal_bullet_scene: PackedScene
@export var gravity_bullet_scene: PackedScene
@export var normal_shoot_interval: float = 0.2
@export var gravity_shoot_interval: float = 0.6
@export var normal_state_duration: float = 2.5
@export var gravity_state_duration: float = 2.5
@export var bob_amplitude: float = 12.0
@export var bob_speed: float = 2.0
@export var drop_chance: float = 0.25
@export var drop_scenes: Array[PackedScene] = []
@export var drop_weights: Array[float] = []
@export var drop_offset: Vector2 = Vector2.ZERO

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var shoot_point_normal: Marker2D = $ShootPointNormal
@onready var shoot_point_gravity: Marker2D = $ShootPointGravity

enum Enemy3State { NORMAL, GRAVITY }

var _state: Enemy3State = Enemy3State.NORMAL
var _state_timer: float = 0.0
var _shoot_timer: float = 0.0
var _bob_time: float = 0.0
var _base_pos: Vector2 = Vector2.ZERO
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	process_priority = 1
	add_to_group("enemy")
	health = clamp(health, 0, max_health)
	_rng.randomize()
	_base_pos = position
	if not normal_bullet_scene:
		normal_bullet_scene = load("res://entities/projectiles/enemy3/enemy3_basic_bullet.tscn") as PackedScene
	if not gravity_bullet_scene:
		gravity_bullet_scene = load("res://entities/projectiles/enemy3/enemy3_gravity_bullet.tscn") as PackedScene
	_set_state(Enemy3State.NORMAL)
	if screen_notifier and not Engine.is_editor_hint():
		_set_active(screen_notifier.is_on_screen())

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	_bob_time += delta
	position.y = _base_pos.y + sin(_bob_time * bob_speed) * bob_amplitude
	_state_timer -= delta
	_shoot_timer -= delta
	if _state_timer <= 0.0:
		_set_state(Enemy3State.GRAVITY if _state == Enemy3State.NORMAL else Enemy3State.NORMAL)
	if _shoot_timer <= 0.0:
		_shoot()

func take_damage(amount: int) -> void:
	if amount <= 0:
		return
	health = max(health - amount, 0)
	if health == 0:
		die()

func die() -> void:
	_try_drop_pickup()
	queue_free()

func _set_state(state: Enemy3State) -> void:
	_state = state
	_state_timer = normal_state_duration if _state == Enemy3State.NORMAL else gravity_state_duration
	_shoot_timer = 0.0
	if anim_player:
		anim_player.play("shooting" if _state == Enemy3State.NORMAL else "gravity")

func _shoot() -> void:
	if _state == Enemy3State.NORMAL:
		_shoot_normal()
		_shoot_timer = normal_shoot_interval
	else:
		_shoot_gravity()
		_shoot_timer = gravity_shoot_interval

func _shoot_normal() -> void:
	if not normal_bullet_scene:
		return
	var bullet = normal_bullet_scene.instantiate()
	var spawn_pos: Vector2 = shoot_point_normal.global_position if shoot_point_normal else global_position
	bullet.global_position = spawn_pos + shoot_offset
	var dir := Vector2.DOWN + (Vector2.RIGHT if facing_right else Vector2.LEFT)
	if bullet.has_method("launch"):
		bullet.launch(dir)
	_add_to_scene(bullet)

func _shoot_gravity() -> void:
	if not gravity_bullet_scene:
		return
	var bullet = gravity_bullet_scene.instantiate()
	var spawn_pos: Vector2 = shoot_point_gravity.global_position if shoot_point_gravity else global_position
	bullet.global_position = spawn_pos + shoot_offset
	if bullet.has_method("launch"):
		bullet.launch(Vector2.RIGHT if facing_right else Vector2.LEFT)
	_add_to_scene(bullet)

func _add_to_scene(node: Node) -> void:
	var root_scene = get_tree().current_scene
	if root_scene:
		root_scene.add_child(node)
	else:
		get_tree().get_root().add_child(node)

func _try_drop_pickup() -> void:
	if Engine.is_editor_hint():
		return
	if drop_scenes.is_empty() or drop_chance <= 0.0:
		return
	if _rng.randf() > drop_chance:
		return
	var index = _pick_weighted_index()
	if index < 0:
		return
	var pickup_scene = drop_scenes[index]
	if pickup_scene == null:
		return
	var spawner = _get_pickup_spawner()
	if spawner and spawner.has_method("spawn_pickup"):
		spawner.spawn_pickup(pickup_scene, global_position + drop_offset)

func _pick_weighted_index() -> int:
	var total := 0.0
	for i in range(drop_scenes.size()):
		var weight = 1.0
		if i < drop_weights.size():
			weight = max(drop_weights[i], 0.0)
		total += weight
	if total <= 0.0:
		return -1
	var roll = _rng.randf() * total
	var accum := 0.0
	for i in range(drop_scenes.size()):
		var weight = 1.0
		if i < drop_weights.size():
			weight = max(drop_weights[i], 0.0)
		accum += weight
		if roll <= accum:
			return i
	return drop_scenes.size() - 1

func _set_active(active: bool) -> void:
	if Engine.is_editor_hint():
		return
	set_process(active)
	set_physics_process(active)
	monitoring = active
	if anim_player:
		if active:
			anim_player.play("shooting" if _state == Enemy3State.NORMAL else "gravity")
		else:
			anim_player.stop()

func _get_pickup_spawner() -> Node:
	return get_tree().get_first_node_in_group("pickup_spawner")

func _on_area_entered(area: Area2D) -> void:
	if not area.is_in_group("player_bullet"):
		return
	var damage := 1
	if area.has_method("get_damage"):
		damage = area.get_damage()
	take_damage(damage)
	area.queue_free()

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	_set_active(true)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	_set_active(false)
