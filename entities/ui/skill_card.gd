extends Control
class_name SkillCard

signal card_selected

@onready var title_label: Label = $Content/VBoxContainer/Title
@onready var description_label: Label = $Content/VBoxContainer/MarginContainer/Description
@onready var content: MarginContainer = $Content
@onready var bubble_border: TextureRect = $TextureRect
@onready var button: Button = $Button

var skill_data: Dictionary
var lerp_time: float = 0.0

func _ready() -> void:
	content.scale.x = -1
	bubble_border.scale.x = -1
	button.scale.x = -1
	content.hide()

func setup(data: Dictionary) -> void:
	skill_data = data
	title_label.text = data.title
	description_label.text = data.description

func _on_button_pressed() -> void:
	emit_signal("card_selected", skill_data) 

func _process(delta: float) -> void:
	print(scale.x)
	if content.scale.x < 1:
		lerp_time += delta * 1.5
		var ease_value = ease(lerp_time, 2) * 2 - 1 
		content.scale.x = ease_value
		bubble_border.scale.x = ease_value
		button.scale.x = ease_value
		if content.scale.x >= 0:
			content.show()
