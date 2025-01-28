extends ProgressBar

func _ready() -> void:
	set_anchors_preset(Control.PRESET_TOP_WIDE)
	position = Vector2(0, 20)
	custom_minimum_size = Vector2(800, 30)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL 
