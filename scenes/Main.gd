extends Node2D

@onready var pause_menu: Control = $CanvasLayer/PauseMenu

func _ready() -> void:
	pause_menu.resume_requested.connect(resume_game)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if !get_tree().paused:
			pause_game()

func pause_game() -> void:
	get_tree().paused = true
	pause_menu.show_menu()

func resume_game() -> void:
	get_tree().paused = false
	pause_menu.hide()
