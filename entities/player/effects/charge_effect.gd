extends AnimatedSprite2D

var r = [0, 90, 45, -45, 30, -60, -30, 60]
var cycle_over: bool = false

# Preload the SpriteFrames (adjust these paths if you place them elsewhere)
var frames1 = preload("res://entities/player/effects/Charge1.tres")
var frames2 = preload("res://entities/player/effects/Charge2.tres")

var curr_frame: SpriteFrames

func set_rotation_from_index(cnt: int) -> void:
	rotation_degrees = r[cnt]

func det_sprite_frames(level: int) -> void:
	match level:
		1:
			curr_frame = frames1
		2:
			curr_frame = frames2
		_:
			curr_frame = frames1

func _ready() -> void:
	sprite_frames = curr_frame
	cycle_over = get_parent().is_cycle_over()
	play("default")
	
	# Dynamically connect signals in Godot 4
	animation_finished.connect(_on_animation_finished)
	frame_changed.connect(_on_frame_changed)

func _on_animation_finished() -> void:
	if cycle_over:
		get_parent().add_anim()
	queue_free()

func _on_frame_changed() -> void:
	if frame == 2 and not cycle_over:
		get_parent().add_anim()
