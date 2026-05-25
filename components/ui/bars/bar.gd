extends NinePatchRect

# In Godot 4, use the @ symbol for annotations. 
# We explicitly type 'initial_size' as a Vector2 for better autocomplete and performance.
@onready var initial_size: Vector2 = size

const MIN_BARS: int = 16
const PIXELS_PER_BAR: int = 2 # The width of one health tick in your texture

# @onready variables ensure these are fetched as soon as the node enters the scene tree
@onready var bg_bar: TextureProgressBar = $bg_bar
@onready var fg_bar: TextureProgressBar = $fg_bar

## Sets maximum number of bars (minimum is 16) and updates the UI constraints
func set_maximum(no_bars: int) -> void:
	# 1. Dynamically resize the NinePatchRect background width
	size.x = initial_size.x + PIXELS_PER_BAR * (no_bars - MIN_BARS)

## Sets the current health fill level across both progress layers
func set_current(no_bars: int) -> void:
	if bg_bar and fg_bar:
		print("Set bars to ", no_bars)
		bg_bar.value = no_bars
		fg_bar.value = no_bars

func _ready() -> void:
	# Testing default state (Max capacity of 22 ticks, currently at 19)
	#set_maximum(20)
	#set_current(16)
	pass
