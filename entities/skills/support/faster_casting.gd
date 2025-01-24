extends Skill
class_name FasterCastingSupport

var required_tags: Array[String] = ["Spell"]  # Works with any castable skill

func _init() -> void:
	skill_name = "Faster Casting Support"
	tags = ["Support", "Cast"]
	setup_base_stats()

func setup_base_stats() -> void:
	modifiers = {
		"cast_speed": {
			"cast_speed_multiplier": {
				"type": "percent",
				"value": 30.0  # 80% increased cast speed
			}
		}
	} 
