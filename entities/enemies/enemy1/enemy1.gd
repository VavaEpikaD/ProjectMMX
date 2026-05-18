@tool
extends Area2D

@export var max_health: int = 3
@export var health: int = 3
@export var projectile_scene: PackedScene = preload("res://entities/projectiles/enemy1/enemy1_projectile.tscn")
@export var shoot_offset: Vector2 = Vector2.ZERO
@export var facing_right: bool = true

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

var _last_texture: Texture2D = null

func _ready() -> void:
	process_priority = 1
	add_to_group("enemy")
	health = clamp(health, 0, max_health)
	if sprite:
		sprite.centered = false
		_update_sprite_offset()
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
	queue_free()

func shoot() -> void:
	if not projectile_scene:
		return
	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position + shoot_offset
	var dir: Vector2 = _get_shoot_direction()
	if projectile.has_method("launch"):
		projectile.launch(dir)
	var root_scene = get_tree().current_scene
	if root_scene:
		root_scene.add_child(projectile)
	else:
		get_tree().get_root().add_child(projectile)

func _get_shoot_direction() -> Vector2:
	return Vector2.RIGHT if facing_right else Vector2.LEFT

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
	area.queue_free()

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	_set_active(true)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	_set_active(false)

