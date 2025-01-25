extends Control
class_name SkillCard

signal card_selected

@onready var title_label: Label = $MarginContainer/VBoxContainer/Title
@onready var description_label: Label = $MarginContainer/VBoxContainer/MarginContainer/Description
@onready var icon: TextureRect = $MarginContainer/VBoxContainer/Icon

var skill_data: Dictionary

func setup(data: Dictionary) -> void:
	skill_data = data
	title_label.text = data.title
	description_label.text = data.description
	if data.has("icon"):
		icon.texture = data.icon

func _on_button_pressed() -> void:
	emit_signal("card_selected", skill_data) 
