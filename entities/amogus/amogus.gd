extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# ensure idle animation on start
	if has_node("AnimationPlayer"):
		$AnimationPlayer.play("idle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not has_node("AnimationPlayer"):
		return

	var anim_player: AnimationPlayer = $AnimationPlayer
	var want_run: bool = Input.is_action_pressed("jump")
	var anim_to_play: String = "run" if want_run else "idle"

	if anim_player.current_animation != anim_to_play:
		anim_player.play(anim_to_play)
