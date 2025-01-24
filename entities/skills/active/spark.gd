extends Skill
class_name SparkSkill

var spark_scene = preload("res://entities/skills/projectiles/spark/SparkProjectile.tscn")

func _init() -> void:
	skill_name = "Spark"
	base_mana_cost = 10.0
	tags = ["Lightning", "Projectile", "Hit"]
	setup_base_stats()

func setup_base_stats() -> void:
	base_stats = {
		"damage": 20.0,  # Base hit damage
		"lightning_damage": 15.0,  # Base lightning damage
		"projectile_speed": 300.0,  # Base projectile speed
		"projectile_amount": 3,  # Base number of projectiles
		"projectile_damage_multiplier": 1.0  # Base projectile damage multiplier
	}
	computed_stats = base_stats.duplicate()

func cast(caster: Node2D) -> void:
	if caster.spend_mana(get_mana_cost()):  # Use new spend_mana function
		spawn_projectiles(caster)

func spawn_projectiles(caster: Node2D) -> void:
	var total_damage = computed_stats.damage * computed_stats.projectile_damage_multiplier
	total_damage += computed_stats.lightning_damage
	
	# Get mouse position for direction
	var mouse_pos = caster.get_global_mouse_position()
	var base_angle = (mouse_pos - caster.global_position).angle()
	
	# Calculate spread angle based on projectile amount
	var spread_angle = PI / 6  # 30 degrees total spread
	var angle_step = spread_angle / max(computed_stats.projectile_amount - 1, 1)
	var start_angle = base_angle - spread_angle / 2
	
	for i in computed_stats.projectile_amount:
		var angle = start_angle + (angle_step * i)
		spawn_spark_projectile(caster, angle, total_damage)

func spawn_spark_projectile(caster: Node2D, angle: float, damage: float) -> void:
	var projectile = spark_scene.instantiate() as SparkProjectile
	if projectile:
		# Add projectile to the game world
		caster.get_tree().current_scene.add_child(projectile)
		
		# Initialize projectile properties
		projectile.init(
			caster.global_position,
			angle,
			damage,
			computed_stats.projectile_speed,
			caster  # Pass the caster reference
		) 
