extends Node
class_name ItemGenerator

enum Rarity { COMMON, MAGIC, RARE }

# Constants for mod counts
const MAGIC_MOD_COUNT = [1, 2]  # Magic items can have 1-2 mods
const RARE_MOD_COUNT = [3, 6]   # Rare items can have 3-6 mods

func generate_item(base_item: BaseItem, item_level: int, rarity: int = -1) -> Item:
	var item = Item.new()
	item.base_item = base_item
	item.item_level = item_level
	
	# Roll base stats
	var rolled_base_stats = {}
	for stat_name in base_item.base_stats:
		var stat_range = base_item.base_stats[stat_name]
		if stat_range is Vector2:
			rolled_base_stats[stat_name] = randi_range(stat_range.x, stat_range.y)
		else:
			rolled_base_stats[stat_name] = stat_range # Use fixed value if not a range
	item.base_stats = rolled_base_stats
	
	# Determine rarity if not specified
	if rarity == -1:
		rarity = roll_rarity()
	item.rarity = rarity
	
	# Add modifiers based on rarity
	match rarity:
		Rarity.COMMON:
			pass # No mods for common items
		Rarity.MAGIC:
			add_magic_mods(item)
		Rarity.RARE:
			add_rare_mods(item)
	
	return item

func roll_rarity() -> int:
	var roll = randf()
	if roll < 1.0:  # 10% chance for rare
		return Rarity.RARE
	elif roll < 0.35:  # 35% chance for magic
		return Rarity.MAGIC
	return Rarity.COMMON

func add_magic_mods(item: Item) -> void:
	var mod_count = randi_range(MAGIC_MOD_COUNT[0], MAGIC_MOD_COUNT[1])
	var prefix_count = randi() % 2  # 0 or 1 prefix
	var suffix_count = mod_count - prefix_count
	
	var possible_mods = ModifierPool.get_possible_mods(item.base_item.item_type)
	
	if prefix_count > 0 and !possible_mods.prefixes.is_empty():
		add_random_mod(item, possible_mods.prefixes, true)
	if suffix_count > 0 and !possible_mods.suffixes.is_empty():
		add_random_mod(item, possible_mods.suffixes, false)

func add_rare_mods(item: Item) -> void:
	var mod_count = randi_range(RARE_MOD_COUNT[0], RARE_MOD_COUNT[1])
	var prefix_count = mod_count / 2  # Split evenly between prefixes and suffixes
	var suffix_count = mod_count - prefix_count
	
	var possible_mods = ModifierPool.get_possible_mods(item.base_item.item_type)
	
	for i in prefix_count:
		if !possible_mods.prefixes.is_empty():
			add_random_mod(item, possible_mods.prefixes, true)
	
	for i in suffix_count:
		if !possible_mods.suffixes.is_empty():
			add_random_mod(item, possible_mods.suffixes, false)

func add_random_mod(item: Item, mod_pool: Array, is_prefix: bool) -> void:
	var valid_mods = get_valid_mods(mod_pool, item)
	if valid_mods.is_empty():
		return
		
	# Select random mod template
	var mod_template = valid_mods[randi() % valid_mods.size()]
	
	# Get valid tiers for item level
	var valid_tiers = []
	for tier in mod_template.tiers:
		if tier.ilvl <= item.item_level:
			valid_tiers.append(tier)
	
	if valid_tiers.is_empty():
		return
		
	# Select random tier
	var tier_data = valid_tiers[randi() % valid_tiers.size()]
	
	# Create modifier
	var mod = Modifier.new()
	mod.name = mod_template.name
	mod.tier = tier_data.tier
	
	# Roll values
	var values = []
	values.append(randi_range(tier_data.values.x, tier_data.values.y))
	
	mod.values = values
	mod.text = mod_template.name.format(values)
	
	if is_prefix:
		item.prefixes.append(mod)
	else:
		item.suffixes.append(mod)

func get_valid_mods(mod_pool: Array, item: Item) -> Array:
	var valid_mods = []
	for mod in mod_pool:
		# Check if any tier is valid for the item level
		for tier in mod.tiers:
			if tier.ilvl <= item.item_level:
				valid_mods.append(mod)
				break
	return valid_mods 
