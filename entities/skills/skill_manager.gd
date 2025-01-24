extends Node
class_name SkillManager

# Structure: Dictionary of arrays where each array represents a skill link
var skill_links: Dictionary = {}

func add_skill_link(link_id: String) -> void:
	if not link_id in skill_links:
		skill_links[link_id] = []

func link_skills(link_id: String, main_skill: Skill, support_skills: Array) -> bool:
	if not link_id in skill_links:
		add_skill_link(link_id)
	
	# Verify support skills can support the main skill
	for support in support_skills:
		if not main_skill.can_support(support):
			push_error("Support skill %s cannot support %s" % [support.skill_name, main_skill.skill_name])
			return false
	
	# Clear existing link
	skill_links[link_id].clear()
	
	# Add main skill
	skill_links[link_id].append(main_skill)
	
	# Add and apply support skills
	for support in support_skills:
		skill_links[link_id].append(support)
		for modifier in support.modifiers.values():
			main_skill.modifiers[support.skill_name] = modifier
	
	# Recompute main skill stats
	main_skill.compute_stats()
	return true

func use_skill(link_id: String, caster: Node2D) -> void:
	if not link_id in skill_links or skill_links[link_id].is_empty():
		return
	
	var main_skill = skill_links[link_id][0]
	main_skill.cast(caster) 
