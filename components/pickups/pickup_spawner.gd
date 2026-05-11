extends Node2D

@export var test_spawn_enabled: bool = true
@export var test_spawn_scene: PackedScene
@export var test_spawn_scene_b: PackedScene
@export var test_spawn_count: int = 5
@export var test_spawn_count_b: int = 5
@export var test_spawn_rect: Rect2 = Rect2(Vector2(0, 0), Vector2(640, 360))
@export var randomize_variant: bool = true
@export_range(0.0, 1.0, 0.05) var big_variant_chance: float = 0.5

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	if not test_spawn_enabled:
		return

	if test_spawn_scene:
		spawn_random(test_spawn_scene, test_spawn_count, test_spawn_rect)
	if test_spawn_scene_b:
		spawn_random(test_spawn_scene_b, test_spawn_count_b, test_spawn_rect)

func spawn_pickup(scene: PackedScene, position: Vector2) -> Node:
	if scene == null:
		return null

	var pickup = scene.instantiate()
	_apply_random_variant(pickup)
	pickup.global_position = position
	var parent = _get_spawn_parent()
	parent.call_deferred("add_child", pickup)
	return pickup

func spawn_random(scene: PackedScene, count: int, rect: Rect2) -> void:
	if scene == null or count <= 0:
		return

	for i in range(count):
		var x = _rng.randf_range(rect.position.x, rect.position.x + rect.size.x)
		var y = _rng.randf_range(rect.position.y, rect.position.y + rect.size.y)
		spawn_pickup(scene, Vector2(x, y))

func _get_spawn_parent() -> Node:
	var root = get_tree().current_scene
	return root if root else self

func _apply_random_variant(pickup: Node) -> void:
	if not randomize_variant:
		return
	if not pickup.has_method("apply_type"):
		return
	var is_big = _rng.randf() < big_variant_chance
	pickup.apply_type(1 if is_big else 0)
