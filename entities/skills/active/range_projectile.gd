extends Skill
class_name RangeProjectileSkill

var projectile_scene = preload("res://entities/skills/projectiles/spark/SparkProjectile.tscn")

func _init() -> void:
	skill_name = "Range Projectile"
	base_mana_cost = 0.0
	base_cast_time = 1.0
	tags = ["Projectile"]
	setup_base_stats()

func setup_base_stats() -> void:
	base_stats = {
		"damage": 15.0,
		"projectile_speed": 500.0,
		"projectile_amount": 3,  # Fire multiple projectiles
		"projectile_duration": 1.5
	}
	computed_stats = base_stats.duplicate()

func cast(caster: Node2D) -> void:
	# Fire projectiles in a spread pattern
	var spread_angle = PI / 3  # 60 degrees total spread
	var angle_step = spread_angle / (computed_stats.projectile_amount - 1)
	var start_angle = -spread_angle / 2
	
	for i in computed_stats.projectile_amount:
		var angle = start_angle + (angle_step * i)
		var direction = Vector2.RIGHT.rotated(angle)
		if caster.has_method("get_target_direction"):
			direction = caster.get_target_direction().rotated(angle)
		
		spawn_projectile(caster, direction)

func spawn_projectile(caster: Node2D, direction: Vector2) -> void:
	var projectile = projectile_scene.instantiate()
	caster.get_tree().current_scene.add_child(projectile)
	projectile.global_position = caster.global_position
	projectile.init(
		caster.global_position,
		direction.angle(),
		computed_stats.damage,
		computed_stats.projectile_speed,
		caster,
		computed_stats.projectile_duration
	) 
