extends Area2D

const BURN_EFFECT_SCENE := preload("res://entities/special_weapon/burn_effect.tscn")
const BURN_EFFECT_NODE_NAME := "BurnEffect"

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
	if area.is_in_group("special_weapon"):
		_show_burn_effect()
	area.queue_free()

func _show_burn_effect() -> void:
	if not BURN_EFFECT_SCENE:
		return
	var target_node: Node2D = anim_sprite if anim_sprite else self
	if target_node.has_node(BURN_EFFECT_NODE_NAME):
		return
	var effect = BURN_EFFECT_SCENE.instantiate() as Node2D
	if not effect:
		return
	effect.name = BURN_EFFECT_NODE_NAME
	target_node.add_child(effect)
	var target_size = _get_visual_size(target_node)
	effect.position = _get_visual_center(target_node, target_size)
	if effect.has_method("start"):
		effect.start(self, target_size)
	elif effect.has_method("set_target_size"):
		effect.set_target_size(target_size)

func _get_visual_size(target: Node2D) -> Vector2:
	if target is Sprite2D:
		var tex = target.texture
		if tex:
			return tex.get_size()
	if target is AnimatedSprite2D:
		var frames = target.sprite_frames
		var anim_name = target.animation
		if frames and anim_name != "" and frames.has_animation(anim_name):
			var tex = frames.get_frame_texture(anim_name, 0)
			if tex:
				return tex.get_size()
	return Vector2(16, 16)

func _get_visual_center(target: Node2D, size: Vector2) -> Vector2:
	if target is Sprite2D:
		return target.offset if target.centered else target.offset + size * 0.5
	if target is AnimatedSprite2D:
		return target.offset if target.centered else target.offset + size * 0.5
	return Vector2.ZERO

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
