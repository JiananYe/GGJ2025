extends Node2D

@onready var label: Label = $Label

var velocity = Vector2(0, -150)  # Move upward faster than damage numbers
var fade_duration = 1.5

func _ready() -> void:
	label.text = "Level Up!"
	label.add_theme_color_override("font_color", Color(1, 0.8, 0))  # Golden color
	
	# Scale up and fade out animation
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.3)
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	tween.chain().tween_callback(queue_free)

func _process(delta: float) -> void:
	position += velocity * delta 