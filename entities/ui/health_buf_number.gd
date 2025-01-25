extends Node2D

@onready var label: Label = $Label

var velocity = Vector2(0, -200)  # Move upward
var fade_duration = 1.0

func _ready() -> void:
	# Start fade out animation
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	tween.tween_callback(queue_free)

func _process(delta: float) -> void:
	position += velocity * delta

func setup(healthbuf: float, is_crit: bool = false) -> void:
	label.text = str(round(healthbuf))
	if is_crit:
		label.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
		label.scale = Vector2(1.5, 1.5) 
