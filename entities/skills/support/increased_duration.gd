extends Skill
class_name IncreasedDurationSupport

var required_tags: Array[String] = ["Projectile"]

func _init() -> void:
	skill_name = "Increased Duration Support"
	tags = ["Support", "Duration"]
	setup_base_stats()

func setup_base_stats() -> void:
	modifiers = {
		"duration": {
			"projectile_duration": {
				"type": "flat",
				"value": 0.5  # Add 1 second to duration
			}
		}
	}
