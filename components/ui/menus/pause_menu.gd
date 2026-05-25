extends CanvasLayer

@export var main_menu_scene: PackedScene = preload("res://components/ui/menus/main_menu.tscn")

const MAIN_MENU_PATH := "res://components/ui/menus/main_menu.tscn"

@onready var continue_button: Button = $Root/Panel/VBoxContainer/ContinueButton
@onready var main_menu_button: Button = $Root/Panel/VBoxContainer/MainMenuButton
@onready var exit_button: Button = $Root/Panel/VBoxContainer/ExitButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if continue_button:
		continue_button.pressed.connect(_on_continue_pressed)
	if main_menu_button:
		main_menu_button.pressed.connect(_on_main_menu_pressed)
	if exit_button:
		exit_button.pressed.connect(_on_exit_pressed)

func _on_continue_pressed() -> void:
	get_tree().paused = false
	queue_free()

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	var err := get_tree().change_scene_to_file(MAIN_MENU_PATH)
	if err != OK and main_menu_scene:
		err = get_tree().change_scene_to_packed(main_menu_scene)
	if err != OK:
		push_error("Failed to change scene to main menu. Error: " + str(err))

func _on_exit_pressed() -> void:
	get_tree().quit()
