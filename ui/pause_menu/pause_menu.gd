extends Control

signal resume_requested

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and visible:
		resume_requested.emit()
		get_viewport().set_input_as_handled()

func show_menu() -> void:
	show()
	$CenterContainer/VBoxContainer/ResumeButton.grab_focus()

func _on_resume_button_pressed() -> void:
	resume_requested.emit() 
