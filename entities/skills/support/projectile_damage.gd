extends Skill
class_name ProjectileDamageSupport

var required_tags: Array[String] = ["Projectile"]

func _init() -> void:
	skill_name = "Projectile Damage Support"
	tags = ["Support", "Projectile", "Damage"]
	setup_base_stats()

func setup_base_stats() -> void:
	modifiers = {
		"damage": {
			"projectile_damage_multiplier": {
				"type": "percent",
				"value": 30.0  # 30% more projectile damage
			}
		}
	} 