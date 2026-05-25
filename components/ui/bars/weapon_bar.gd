extends NinePatchRect

@onready var initial_size: Vector2 = size

const MIN_BARS: int = 14
const PIXELS_PER_BAR: int = 2

@onready var bg_bar: TextureProgressBar = $bg_bar
@onready var fg_bar: TextureProgressBar = $fg_bar

## Sets maximum number of bars (minimum is 16) and updates the container width
func set_maximum(no_bars: int) -> void:
	# Dynamically resize the NinePatchRect background width
	size.x = initial_size.x + PIXELS_PER_BAR * (no_bars - MIN_BARS)
	# max_value stays at a constant 32 safely via the inspector!

## Sets the current ammo/energy fill level across both progress layers
func set_current(no_bars: float) -> void:
	if bg_bar and fg_bar:
		bg_bar.value = no_bars
		fg_bar.value = no_bars

func _ready() -> void:
	# Testing default state (Max capacity of 22 ticks, currently at 19)
	set_maximum(30)
	set_current(17)
