@tool
extends CharacterBody2D

@export var max_health: int = 3
@export var health: int = 3
@export var speed: float = 100.0
@export var damage: int = 1
@export var facing_right: bool = true
@export var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var damage_area: Area2D = $DamageArea

var _has_been_seen: bool = false

func _ready() -> void:
	process_priority = 1
	add_to_group("enemy")
	health = clamp(health, 0, max_health)
	if sprite:
		sprite.centered = true
		sprite.offset = Vector2.ZERO
		_update_facing()
	if anim_player:
		anim_player.play("default")
	if screen_notifier and not Engine.is_editor_hint():
		_has_been_seen = screen_notifier.is_on_screen()
		_set_active(_has_been_seen)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if not is_on_floor():
		velocity.y += gravity * delta
	velocity.x = (1 if facing_right else -1) * speed
	move_and_slide()
	if is_on_wall():
		facing_right = not facing_right
		_update_facing()

func take_damage(amount: int) -> void:
	if amount <= 0:
		return
	health = max(health - amount, 0)
	if health == 0:
		die()

func die() -> void:
	queue_free()

func _update_facing() -> void:
	if sprite:
		sprite.flip_h = facing_right

func _set_active(active: bool) -> void:
	if Engine.is_editor_hint():
		return
	set_process(active)
	set_physics_process(active)
	if damage_area:
		damage_area.monitoring = active
	if anim_player:
		if active:
			anim_player.play("default")
		else:
			anim_player.stop()

func _on_damage_area_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	if body.has_method("take_damage"):
		body.take_damage(damage)

func _on_damage_area_area_entered(area: Area2D) -> void:
	if not area.is_in_group("player_bullet"):
		return
	var bullet_damage := 1
	if area.has_method("get_damage"):
		bullet_damage = area.get_damage()
	take_damage(bullet_damage)
	area.queue_free()

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	_has_been_seen = true
	_set_active(true)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if not _has_been_seen:
		_set_active(false)
