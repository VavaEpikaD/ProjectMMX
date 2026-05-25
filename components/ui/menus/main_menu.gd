extends Control

@export var level_scene: PackedScene = preload("res://level/DebugLevel.tscn")

@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var exit_button: Button = $VBoxContainer/ExitButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if play_button:
		play_button.pressed.connect(_on_play_pressed)
	if exit_button:
		exit_button.pressed.connect(_on_exit_pressed)

func _on_play_pressed() -> void:
	get_tree().paused = false
	if level_scene:
		get_tree().change_scene_to_packed(level_scene)

func _on_exit_pressed() -> void:
	get_tree().quit()
