extends Control

@onready var label = $Label
@onready var animation_player = $AnimationPlayer

func show_difficulty(level: int) -> void:
	label.text = "Difficulty %d" % level
	animation_player.play("fade") 
