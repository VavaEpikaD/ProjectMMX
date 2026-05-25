extends Node2D

const CHARGE_EFFECT_SCENE = preload("res://entities/player/effects/charge_effect.tscn")

var cnt: int = -1
var cycle_over_flag: bool = false
var is_charging: bool = false
var is_charging2: bool = false
var charge_level: int = 0

func update_charge_level(level: int) -> void:
	charge_level = level

func incr() -> void:
	cnt += 1
	if cnt == 8:
		cycle_over_flag = true
		cnt = 0
	else:
		cycle_over_flag = false

func is_cycle_over() -> bool:
	return cycle_over_flag

func set_charging(charge_flag: bool) -> void:
	is_charging = charge_flag
	
func set_charging_lvl2(charge_flag: bool) -> void:
	is_charging2 = charge_flag

func add_anim() -> void:
	if charge_level > 0:
		incr()
		var charge1 = CHARGE_EFFECT_SCENE.instantiate()
		charge1.det_sprite_frames(charge_level)
		charge1.set_rotation_from_index(cnt)
		add_child(charge1)

func start_charging_effect() -> void:
	cnt = -1
	cycle_over_flag = false
	add_anim()
