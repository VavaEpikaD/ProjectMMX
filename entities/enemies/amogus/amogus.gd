extends Area2D

@export var max_health: int = 3
@export var health: int = 3
@export var drop_chance: float = 0.25
@export var drop_scenes: Array[PackedScene] = []
@export var drop_weights: Array[float] = []
@export var drop_offset: Vector2 = Vector2.ZERO

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	add_to_group("enemy")
	health = clamp(health, 0, max_health)
	_rng.randomize()
	if anim_sprite:
		anim_sprite.play("default")

func take_damage(amount: int) -> void:
	if amount <= 0:
		return
	health = max(health - amount, 0)
	if health == 0:
		die()

func die() -> void:
	_try_drop_pickup()
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if not area.is_in_group("player_bullet"):
		return
	var damage = 1
	if area.has_method("get_damage"):
		damage = area.get_damage()
	take_damage(damage)
	area.queue_free()

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

func _get_pickup_spawner() -> Node:
	return get_tree().get_first_node_in_group("pickup_spawner")
