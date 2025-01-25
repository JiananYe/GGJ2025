extends Resource
class_name Item

var base_item: BaseItem
var rarity: int
var item_level: int
var prefixes: Array[Modifier] = []
var suffixes: Array[Modifier] = []

func get_display_name() -> String:
	var rarity_prefix = ["", "Magic ", "Rare "][rarity]
	return rarity_prefix + base_item.name

func get_modifier_descriptions() -> Array[String]:
	var descriptions: Array[String] = []
	for prefix in prefixes:
		descriptions.append(prefix.text)
	for suffix in suffixes:
		descriptions.append(suffix.text)
	return descriptions 