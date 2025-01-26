extends Node

const BASE_ITEMS = {
	"Wooden Staff": {
		"type": "staff",
		"stats": {
			"spell_damage": Vector2(2, 5),
			"cast_speed": 1.2
		}
	},
	"Leather Boots": {
		"type": "boots",
		"stats": {
			"armor": Vector2(2, 4),
			"movement_speed": 1.1
		}
	},
	"Iron Ring": {
		"type": "ring",
		"stats": {
			"life": Vector2(10, 20)
		}
	},
	"Amber Amulet": {
		"type": "amulet",
		"stats": {
			"strength": Vector2(20, 30)
		}
	},
	"Leather Belt": {
		"type": "belt",
		"stats": {
			"life": Vector2(25, 35)
		}
	},
	"Rusty Helmet": {
		"type": "helmet",
		"stats": {
			"armor": Vector2(3, 6)
		}
	},
	"Tattered Body Armor": {
		"type": "body_armor",
		"stats": {
			"armor": Vector2(8, 12)
		}
	},
	"Cloth Bracers": {
		"type": "bracers",
		"stats": {
			"armor": Vector2(1, 3),
			"cast_speed": 1.1
		}
	}
}

static func get_random_base_item() -> BaseItem:
	var item_names = BASE_ITEMS.keys()
	var random_name = item_names[randi() % item_names.size()]
	var item_data = BASE_ITEMS[random_name]
	
	var base_item = BaseItem.new()
	base_item.name = random_name
	base_item.item_type = item_data.type
	base_item.base_stats = item_data.stats
	
	return base_item 
