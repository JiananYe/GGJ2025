extends Resource
class_name Skill

# Skill Properties
var skill_name: String
var base_mana_cost: float
var level: int = 1
var tags: Array[String] = []
var modifiers: Dictionary = {}

# Base skill stats
var base_stats: Dictionary = {}
var computed_stats: Dictionary = {}

func _init() -> void:
	setup_base_stats()

func setup_base_stats() -> void:
	# Override in child classes
	pass

func compute_stats() -> void:
	computed_stats = base_stats.duplicate()
	
	# Apply modifiers from support skills and other sources
	for modifier in modifiers.values():
		apply_modifier(modifier)

func apply_modifier(modifier: Dictionary) -> void:
	for stat in modifier:
		if stat in computed_stats:
			if modifier[stat].type == "flat":
				computed_stats[stat] += modifier[stat].value
			elif modifier[stat].type == "percent":
				computed_stats[stat] *= (1 + modifier[stat].value / 100.0)

func can_support(support_skill: Skill) -> bool:
	# Check if the support skill can be applied to this skill
	for required_tag in support_skill.required_tags:
		if not required_tag in tags:
			return false
	return true

func get_mana_cost() -> float:
	var cost = base_mana_cost
	# Apply mana cost modifiers here
	return cost 
