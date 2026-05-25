extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var hp_bar: NinePatchRect = $UI/Bar

func _ready() -> void:
	if player and hp_bar:
		# Connect the player's signals to the HP bar's functions
		player.max_health_changed.connect(hp_bar.set_maximum)
		player.health_changed.connect(hp_bar.set_current)
