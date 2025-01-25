extends Resource
class_name ModifierData

var name: String
var tier: int
var item_level: int
var weight: int = 1000

var value_ranges: Array[Vector2] = []
var mod_text: String

func parse_ranges() -> void:
	# Extract ranges from name like "(5-10)% increased damage"
	var regex = RegEx.new()
	regex.compile("\\((\\d+)-(\\d+)\\)")
	var matches = regex.search_all(name)
	
	for match_result in matches:
		var min_val = match_result.get_string(1).to_float()
		var max_val = match_result.get_string(2).to_float()
		value_ranges.append(Vector2(min_val, max_val))
	
	# Store template for text generation
	mod_text = name
	for i in range(matches.size()):
		mod_text = mod_text.replace(matches[i].get_string(), "{%d}" % i)

func roll_values() -> Modifier:
	var mod = Modifier.new()
	mod.name = name
	mod.tier = tier
	
	var rolled_values = []
	for range in value_ranges:
		rolled_values.append(randf_range(range.x, range.y))
	
	mod.values = rolled_values
	mod.text = mod_text.format(rolled_values)
	return mod 