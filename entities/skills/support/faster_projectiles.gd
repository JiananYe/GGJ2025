extends Skill
class_name FasterProjectilesSupport

var required_tags: Array[String] = ["Projectile"]

func _init() -> void:
	skill_name = "Faster Projectiles Support"
	tags = ["Support", "Projectile"]
	setup_base_stats()

func setup_base_stats() -> void:
	modifiers = {
		"projectile": {
			"projectile_speed": {
				"type": "percent",
				"value": 50.0  # 50% increased projectile speed
			}
		}
	} 