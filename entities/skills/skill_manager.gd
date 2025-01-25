extends Node
class_name SkillManager

# Dictionary to store skill links
# Format: { "link_name": { "main": main_skill, "support": [support_skills] } }
var skill_links: Dictionary = {}

func add_skill_link(link_name: String) -> void:
	if !skill_links.has(link_name):
		skill_links[link_name] = {
			"main": null,
			"support": []
		}

func link_skills(link_name: String, main_skill: Skill, support_skills: Array = []) -> void:
	if !skill_links.has(link_name):
		add_skill_link(link_name)
	
	skill_links[link_name].main = main_skill
	skill_links[link_name].support = support_skills
	
	# Reset main skill stats before applying new modifiers
	main_skill.setup_base_stats()
	
	# Apply support skill modifiers to main skill
	for support in support_skills:
		apply_support_modifiers(main_skill, support)
	
	# Compute final stats after all modifiers are applied
	main_skill.compute_stats()

func get_main_skill(link_name: String) -> Skill:
	if skill_links.has(link_name):
		return skill_links[link_name].main
	return null

func get_support_skills(link_name: String) -> Array:
	if skill_links.has(link_name):
		return skill_links[link_name].support
	return []

func use_skill(link_name: String, caster: Node2D) -> void:
	if skill_links.has(link_name) and skill_links[link_name].main != null:
		skill_links[link_name].main.cast(caster)

func apply_support_modifiers(main_skill: Skill, support_skill: Skill) -> void:
	# Check if support skill can support this main skill
	if !can_support(main_skill, support_skill):
		return
		
	# Apply modifiers from support skill to main skill
	for category in support_skill.modifiers:
		if !main_skill.modifiers.has(category):
			main_skill.modifiers[category] = {}
		
		# Add modifiers from support skill
		for stat in support_skill.modifiers[category]:
			main_skill.modifiers[category][stat] = support_skill.modifiers[category][stat]

func can_support(main_skill: Skill, support_skill: Skill) -> bool:
	# Check if main skill has any of the required tags
	if !support_skill.get("required_tags"):
		return true
		
	for tag in support_skill.required_tags:
		if tag in main_skill.tags:
			return true
	return false 
