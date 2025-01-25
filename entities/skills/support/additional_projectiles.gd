extends Skill
class_name AdditionalProjectilesSupport

var required_tags: Array[String] = ["Projectile"]

func _init() -> void:
	skill_name = "Additional Projectiles"
	tags = ["Support", "Projectile"]
	setup_base_stats()

func setup_base_stats() -> void:
	modifiers = {
		"projectile": {
			"projectile_amount": {
				"type": "flat",
				"value": 2.0
			},
			"projectile_damage_multiplier": {
				"type": "percent",
				"value": -10.0
			}
		}
	} 
