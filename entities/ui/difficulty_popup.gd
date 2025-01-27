extends Control

func _ready() -> void:
	modulate.a = 0.0
	show_popup()

func setup(level: int) -> void:
	var label = $Label
	var sub_label = $SubLabel
	label.text = "Difficulty Increased to Level %d!" % level
	sub_label.text = "Monsters are %.1fx stronger now" % (1.0 + (level * 0.2))
	print("Difficulty increased to level ", level, " (monsters are ", 1.0 + (level * 0.2), "x stronger)")

func show_popup() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	tween.tween_interval(2.0)
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free) 
