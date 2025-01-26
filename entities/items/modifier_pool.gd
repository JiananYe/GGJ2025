extends Node
class_name ModifierPool

enum ModifierType {
	PREFIX,
	SUFFIX
}

class ModifierTemplate:
	var name: String
	var type: ModifierType
	var tiers: Array
	var tags: Array[String]
	
	func _init(p_name: String, p_type: ModifierType, p_tiers: Array, p_tags: Array[String] = []):
		name = p_name
		type = p_type
		tiers = p_tiers
		tags = p_tags

static func get_physical_damage() -> ModifierTemplate:
	return ModifierTemplate.new(
		"Adds {0} Physical Damage",
		ModifierType.PREFIX,
		[
			{"tier": 1, "ilvl": 50, "values": Vector2(15, 25), "weight": 1000},
			{"tier": 2, "ilvl": 30, "values": Vector2(10, 15), "weight": 1000},
			{"tier": 3, "ilvl": 1, "values": Vector2(5, 10), "weight": 1000}
		],
		["attack", "physical"]
	)

static func get_spell_damage() -> ModifierTemplate:
	return ModifierTemplate.new(
		"{0}% Increased Spell Damage",
		ModifierType.PREFIX,
		[
			{"tier": 1, "ilvl": 50, "values": Vector2(20, 30), "weight": 1000},
			{"tier": 2, "ilvl": 30, "values": Vector2(15, 20), "weight": 1000},
			{"tier": 3, "ilvl": 1, "values": Vector2(10, 15), "weight": 1000}
		],
		["spell", "damage"]
	)

static func get_cast_speed() -> ModifierTemplate:
	return ModifierTemplate.new(
		"{0}% Increased Cast Speed",
		ModifierType.SUFFIX,
		[
			{"tier": 1, "ilvl": 50, "values": Vector2(15, 20), "weight": 1000},
			{"tier": 2, "ilvl": 30, "values": Vector2(10, 15), "weight": 1000},
			{"tier": 3, "ilvl": 1, "values": Vector2(5, 10), "weight": 1000}
		],
		["spell", "speed"]
	)

static func get_armor() -> ModifierTemplate:
	return ModifierTemplate.new(
		"{0}% Increased Armor",
		ModifierType.PREFIX,
		[
			{"tier": 1, "ilvl": 50, "values": Vector2(80, 100), "weight": 1000},
			{"tier": 2, "ilvl": 30, "values": Vector2(60, 80), "weight": 1000},
			{"tier": 3, "ilvl": 1, "values": Vector2(40, 60), "weight": 1000}
		],
		["defense", "armor"]
	)

static func get_life() -> ModifierTemplate:
	return ModifierTemplate.new(
		"+{0} to Maximum Life",
		ModifierType.PREFIX,
		[
			{"tier": 1, "ilvl": 50, "values": Vector2(80, 100), "weight": 1000},
			{"tier": 2, "ilvl": 30, "values": Vector2(60, 80), "weight": 1000},
			{"tier": 3, "ilvl": 1, "values": Vector2(40, 60), "weight": 1000}
		],
		["defense", "life"]
	)

static func get_mana() -> ModifierTemplate:
	return ModifierTemplate.new(
		"+{0} to Maximum Mana",
		ModifierType.SUFFIX,
		[
			{"tier": 1, "ilvl": 50, "values": Vector2(70, 90), "weight": 1000},
			{"tier": 2, "ilvl": 30, "values": Vector2(50, 70), "weight": 1000},
			{"tier": 3, "ilvl": 1, "values": Vector2(30, 50), "weight": 1000}
		],
		["defense", "mana"]
	)

static func get_movement_speed() -> ModifierTemplate:
	return ModifierTemplate.new(
		"{0}% Increased Movement Speed",
		ModifierType.SUFFIX,
		[
			{"tier": 1, "ilvl": 50, "values": Vector2(25, 30), "weight": 1000},
			{"tier": 2, "ilvl": 30, "values": Vector2(20, 25), "weight": 1000},
			{"tier": 3, "ilvl": 1, "values": Vector2(15, 20), "weight": 1000}
		],
		["speed"]
	)

static func get_projectile_speed() -> ModifierTemplate:
	return ModifierTemplate.new(
		"{0}% Increased Projectile Speed",
		ModifierType.SUFFIX,
		[
			{"tier": 1, "ilvl": 50, "values": Vector2(25, 30), "weight": 1000},
			{"tier": 2, "ilvl": 30, "values": Vector2(20, 25), "weight": 1000},
			{"tier": 3, "ilvl": 1, "values": Vector2(15, 20), "weight": 1000}
		],
		["projectile", "speed"]
	)

static func get_all_attributes() -> ModifierTemplate:
	return ModifierTemplate.new(
		"+{0} to All Attributes",
		ModifierType.PREFIX,
		[
			{"tier": 1, "ilvl": 50, "values": Vector2(15, 20), "weight": 1000},
			{"tier": 2, "ilvl": 30, "values": Vector2(10, 15), "weight": 1000},
			{"tier": 3, "ilvl": 1, "values": Vector2(5, 10), "weight": 1000}
		],
		["attribute"]
	)

static func get_critical_chance() -> ModifierTemplate:
	return ModifierTemplate.new(
		"{0}% Increased Critical Strike Chance",
		ModifierType.SUFFIX,
		[
			{"tier": 1, "ilvl": 50, "values": Vector2(25, 35), "weight": 1000},
			{"tier": 2, "ilvl": 30, "values": Vector2(15, 25), "weight": 1000},
			{"tier": 3, "ilvl": 1, "values": Vector2(10, 15), "weight": 1000}
		],
		["critical"]
	)

static func get_possible_mods(item_type: String) -> Dictionary:
	var item_mods = {
		"body_armor": {
			"prefixes": [get_armor(), get_life()],
			"suffixes": [get_movement_speed(), get_mana()]
		},
		"helmet": {
			"prefixes": [get_armor(), get_life()],
			"suffixes": [get_mana(), get_cast_speed()]
		},
		"boots": {
			"prefixes": [get_armor(), get_life()],
			"suffixes": [get_movement_speed(), get_mana()]
		},
		"staff": {
			"prefixes": [get_spell_damage(), get_physical_damage()],
			"suffixes": [get_cast_speed(), get_projectile_speed()]
		},
		"axe": {
			"prefixes": [get_physical_damage()],
			"suffixes": [get_movement_speed()]
		},
		"ring": {
			"prefixes": [get_life(), get_all_attributes()],
			"suffixes": [get_mana(), get_cast_speed(), get_critical_chance()]
		},
		"amulet": {
			"prefixes": [get_spell_damage(), get_all_attributes()],
			"suffixes": [get_critical_chance(), get_cast_speed()]
		}
	}
	
	if item_mods.has(item_type):
		return item_mods[item_type]
	return {"prefixes": [], "suffixes": []} 
