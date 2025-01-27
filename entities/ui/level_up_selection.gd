extends Control

signal skill_selected(skill_data: Dictionary)

@onready var cards_container = $CardsContainer
var skill_card_scene = preload("res://entities/ui/SkillCard.tscn")

var available_skills: Array[Dictionary] = []
var player: Node  # Reference to player to check owned skills

func _ready() -> void:
	hide()
	get_tree().paused = false
	# Get player reference
	player = get_tree().get_first_node_in_group("player")
	load_available_skills()

func load_available_skills() -> void:
	available_skills.clear()
	
	# Add main skill level up option
	var main_skill = player.skill_manager.get_main_skill("primary_attack")
	if main_skill:
		var main_skill_data = {
			"title": "Level Up %s" % main_skill.skill_name,
			"description": main_skill.get_level_up_description(),
			"type": "main",
			"skill": "spark"  # This will be used to identify it's a main skill level up
		}
		available_skills.append(main_skill_data)
	
	# Directly reference support skills
	var support_skills = {
		"AdditionalProjectiles": preload("res://entities/skills/support/additional_projectiles.gd"),
		"FasterCasting": preload("res://entities/skills/support/faster_casting.gd"),
		"FasterProjectiles": preload("res://entities/skills/support/faster_projectiles.gd"),
		"IncreasedDuration": preload("res://entities/skills/support/increased_duration.gd"),
		"ProjectileDamage": preload("res://entities/skills/support/projectile_damage.gd")
	}
	
	for skill_name in support_skills:
		var skill_script = support_skills[skill_name]
		if skill_script:
			var skill_instance = skill_script.new()
			if skill_instance is Skill:  # Verify it's a skill
				# Skip if player already has this skill
				if !has_skill(skill_name):
					var skill_data = {
						"title": skill_instance.skill_name,
						"description": get_skill_description(skill_instance),
						"type": "support",
						"skill": skill_name
					}
					available_skills.append(skill_data)

func has_skill(skill_name: String) -> bool:
	if !player or !player.skill_manager:
		return false
		
	var current_supports = player.skill_manager.get_support_skills("primary_attack")
	for support in current_supports:
		if support.get_script().get_path().get_basename().get_file().to_pascal_case() == skill_name:
			return true
	return false

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
	# Reload available skills to get current state
	load_available_skills()
	
	# Randomly select 3 different skills
	var selected_skills = []
	var available = available_skills.duplicate()
	
	# If we have less than 3 available skills, show all of them
	var num_to_show = mini(3, available.size())
	
	for i in num_to_show:
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
	if skill_data.type == "main":
		# Level up main skill
		var main_skill = player.skill_manager.get_main_skill("primary_attack")
		if main_skill and main_skill.has_method("level_up"):
			main_skill.level_up()
	else:
		# Handle support skill selection (existing code)
		var skill_class = load("res://entities/skills/support/" + skill_data.skill.to_snake_case() + ".gd")
		if skill_class:
			var new_skill = skill_class.new()
			var main_skill = player.skill_manager.get_main_skill("primary_attack")
			var current_supports = player.skill_manager.get_support_skills("primary_attack")
			
			if main_skill:
				player.skill_manager.link_skills("primary_attack", main_skill, current_supports + [new_skill])
	
	hide()
	get_tree().paused = false 
