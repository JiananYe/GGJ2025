extends Control

signal skill_selected(skill_data: Dictionary)

@onready var cards_container = $CardsContainer
var skill_card_scene = preload("res://entities/ui/SkillCard.tscn")

var available_skills: Array[Dictionary] = []

func _ready() -> void:
	hide()
	get_tree().paused = false
	load_available_skills()

func load_available_skills() -> void:
	var support_dir = "res://entities/skills/support"
	var dir = DirAccess.open(support_dir)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".gd") and not file_name.begins_with("."):
				var skill_path = support_dir.path_join(file_name)
				var skill_script = load(skill_path)
				if skill_script:
					var skill_instance = skill_script.new()
					if skill_instance is Skill:  # Verify it's a skill
						var skill_data = {
							"title": skill_instance.skill_name,
							"description": get_skill_description(skill_instance),
							"type": "support",
							"skill": file_name.get_basename().to_pascal_case()
						}
						available_skills.append(skill_data)
			file_name = dir.get_next()
		dir.list_dir_end()

func get_skill_description(skill: Skill) -> String:
	var description = ""
	
	# Go through modifiers to build description
	for category in skill.modifiers:
		for modifier in skill.modifiers[category]:
			var mod = skill.modifiers[category][modifier]
			var value = mod.value
			var type = mod.type
			
			# Format the modifier description
			if type == "percent":
				if value > 0:
					description += str(value) + "% increased "
				else:
					description += str(abs(value)) + "% decreased "
			else:  # flat
				if value > 0:
					description += "+" + str(value) + " "
				else:
					description += str(value) + " "
			
			# Add readable modifier name
			description += modifier.replace("_", " ").trim_suffix(" multiplier") + "\n"
	
	return description.strip_edges()

func show_selection() -> void:
	# Randomly select 3 different skills
	var selected_skills = []
	var available = available_skills.duplicate()
	for i in 3:
		if available.size() > 0:
			var index = randi() % available.size()
			selected_skills.append(available[index])
			available.remove_at(index)
	
	# Clear existing cards
	for child in cards_container.get_children():
		child.queue_free()
	
	# Create new cards
	for skill_data in selected_skills:
		var card = skill_card_scene.instantiate()
		cards_container.add_child(card)
		card.setup(skill_data)
		card.card_selected.connect(_on_card_selected)
	
	show()
	get_tree().paused = true

func _on_card_selected(skill_data: Dictionary) -> void:
	emit_signal("skill_selected", skill_data)
	hide()
	get_tree().paused = false 
