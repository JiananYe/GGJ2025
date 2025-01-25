extends Resource
class_name Skill

# Skill Properties
var skill_name: String
var base_mana_cost: float
var level: int = 1
var tags: Array[String] = []
var modifiers: Dictionary = {}
var base_cast_time: float = 1.0  # Base time to cast in seconds
var cast_speed_multiplier: float = 1.0  # Add this for cast speed modifications

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
	cast_speed_multiplier = 1.0  # Reset cast speed multiplier
	
	# Apply modifiers from support skills and other sources
	for category_mods in modifiers.values():
		apply_modifier(category_mods)

func apply_modifier(modifier: Dictionary) -> void:
	# Check if this is a category of modifiers
	if modifier.has("modifiers"):
		var mods = modifier.modifiers
		for stat in mods:
			if stat == "cast_speed_multiplier":
				cast_speed_multiplier *= (1 + mods[stat].value / 100.0)
			elif stat in computed_stats:
				if mods[stat].type == "flat":
					computed_stats[stat] += mods[stat].value
				elif mods[stat].type == "percent":
					computed_stats[stat] *= (1 + mods[stat].value / 100.0)
	# Legacy support for direct modifiers
	else:
		for stat in modifier:
			if stat == "cast_speed_multiplier":
				cast_speed_multiplier *= (1 + modifier[stat].value / 100.0)
			elif stat in computed_stats:
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

func get_cast_time(caster: Node2D) -> float:
	var base_speed = 1.0
	if caster.has_method("get_total_cast_speed"):
		base_speed = caster.get_total_cast_speed()
	return base_cast_time / (base_speed * cast_speed_multiplier)

func get_animation_speed(caster: Node2D) -> float:
	var base_speed = 1.0
	if caster.has_method("get_total_cast_speed"):
		base_speed = caster.get_total_cast_speed()
	return base_speed * cast_speed_multiplier 
