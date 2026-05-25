@tool
extends Area2D

const BURN_EFFECT_SCENE := preload("res://entities/special_weapon/burn_effect.tscn")
const BURN_EFFECT_NODE_NAME := "BurnEffect"

@export var max_health: int = 3
@export var health: int = 3
@export var projectile_scene: PackedScene = preload("res://entities/projectiles/enemy1/enemy1_projectile.tscn")
@export var shoot_offset: Vector2 = Vector2.ZERO
@export var facing_right: bool = true:
	set(value):
		facing_right = value
		_update_facing()
@export var drop_chance: float = 0.25
@export var drop_scenes: Array[PackedScene] = []
@export var drop_weights: Array[float] = []
@export var drop_offset: Vector2 = Vector2.ZERO

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

var _last_texture: Texture2D = null
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	process_priority = 1
	add_to_group("enemy")
	health = clamp(health, 0, max_health)
	_rng.randomize()
	if sprite:
		sprite.centered = false
		_update_sprite_offset()
	_update_facing()
	if anim_player:
		anim_player.play("default")
	if screen_notifier and not Engine.is_editor_hint():
		_set_active(screen_notifier.is_on_screen())

func _process(_delta: float) -> void:
	_update_sprite_offset()

func take_damage(amount: int) -> void:
	if amount <= 0:
		return
	health = max(health - amount, 0)
	if health == 0:
		die()

func die() -> void:
	_try_drop_pickup()
	queue_free()

func shoot() -> void:
	if not projectile_scene:
		return
	var projectile = projectile_scene.instantiate()
	var actual_offset = shoot_offset
	if facing_right:
		actual_offset.x = abs(actual_offset.x)
	else:
		actual_offset.x = -abs(actual_offset.x)
	projectile.global_position = global_position + actual_offset
	var dir: Vector2 = _get_shoot_direction()
	if projectile.has_method("launch"):
		projectile.launch(dir)
	var root_scene = get_tree().current_scene
	if root_scene:
		root_scene.add_child(projectile)
	else:
		get_tree().get_root().add_child(projectile)

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

func _get_shoot_direction() -> Vector2:
	return Vector2.RIGHT if facing_right else Vector2.LEFT

func _update_facing() -> void:
	if not is_inside_tree():
		return
	if sprite:
		sprite.flip_h = facing_right

func _update_sprite_offset() -> void:
	if not sprite:
		return
	var texture = sprite.texture
	if not texture:
		return
	if texture == _last_texture:
		return
	_last_texture = texture
	var size = texture.get_size()
	sprite.offset = Vector2(-size.x, -size.y)

func _set_active(active: bool) -> void:
	if Engine.is_editor_hint():
		return
	set_process(active)
	set_physics_process(active)
	monitoring = active
	if anim_player:
		if active:
			anim_player.play("default")
			_update_sprite_offset()
		else:
			anim_player.stop()

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
	var target_node: Node2D = sprite if sprite else self
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

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	_set_active(true)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	_set_active(false)

