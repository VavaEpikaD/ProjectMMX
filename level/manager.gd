extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var hp_bar: NinePatchRect = $UI/Bar
@onready var ending_controller: Node2D = $EndingController

@export var pause_menu_scene: PackedScene = preload("res://components/ui/menus/pause_menu.tscn")
@export var game_over_menu_scene: PackedScene = preload("res://components/ui/menus/game_over_menu.tscn")
@export var main_menu_scene: PackedScene = preload("res://components/ui/menus/main_menu.tscn")

var _pause_menu: CanvasLayer
var _game_over_menu: CanvasLayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if player and hp_bar:
		# Connect the player's signals to the HP bar's functions
		player.max_health_changed.connect(hp_bar.set_maximum)
		player.health_changed.connect(hp_bar.set_current)
		if player.has_signal("died"):
			player.died.connect(_on_player_died)
	if ending_controller and ending_controller.has_signal("game_over_requested"):
		ending_controller.game_over_requested.connect(_on_end_game_over_requested)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if _game_over_menu and is_instance_valid(_game_over_menu):
			return
		if get_tree().paused:
			_close_pause_menu()
		else:
			_open_pause_menu()

func _open_pause_menu() -> void:
	if _pause_menu and is_instance_valid(_pause_menu):
		return
	if not pause_menu_scene:
		return
	_pause_menu = pause_menu_scene.instantiate() as CanvasLayer
	if _pause_menu:
		_pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	if _pause_menu and _pause_menu.has_method("set"):
		_pause_menu.main_menu_scene = main_menu_scene
	_pause_menu.tree_exited.connect(_on_pause_menu_exited)
	add_child(_pause_menu)
	get_tree().paused = true

func _close_pause_menu() -> void:
	if _pause_menu and is_instance_valid(_pause_menu):
		_pause_menu.queue_free()
	_pause_menu = null
	get_tree().paused = false

func _on_pause_menu_exited() -> void:
	_pause_menu = null

func _on_player_died() -> void:
	_show_game_over_menu()

func _on_end_game_over_requested() -> void:
	_show_game_over_menu()

func _show_game_over_menu() -> void:
	if _game_over_menu and is_instance_valid(_game_over_menu):
		return
	if not game_over_menu_scene:
		return
	_game_over_menu = game_over_menu_scene.instantiate() as CanvasLayer
	if _game_over_menu:
		_game_over_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	if _game_over_menu and _game_over_menu.has_method("set"):
		_game_over_menu.main_menu_scene = main_menu_scene
	_game_over_menu.tree_exited.connect(_on_game_over_menu_exited)
	add_child(_game_over_menu)
	get_tree().paused = true

func _on_game_over_menu_exited() -> void:
	_game_over_menu = null
