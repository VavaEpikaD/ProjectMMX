extends CharacterBody2D

@export var weapon_add_amount: int = 1
@export var lifetime: float = 7.0

var _time_alive: float = 0.0

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var opened = false

func _ready() -> void:
	if anim_sprite:
		anim_sprite.play("open")

func _process(delta: float) -> void:
	if lifetime <= 0.0:
		return
	_time_alive += delta
	if _time_alive >= lifetime:
		queue_free()
		
func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()
	
	if is_on_floor() and not opened:
		anim_sprite.play("open")
		opened = true

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("add_weapon_energy"):
		body.add_weapon_energy(weapon_add_amount)
		queue_free()


func _on_animated_sprite_2d_animation_finished() -> void:
	if anim_sprite.animation == "open" and is_on_floor():
		anim_sprite.play("default")
		opened = true
