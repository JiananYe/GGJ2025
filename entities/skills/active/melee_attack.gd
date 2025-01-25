extends Skill
class_name MeleeAttackSkill

var attack_range: float = 100.0
var attack_angle: float = PI/2  # 90 degrees attack arc

func _init() -> void:
	skill_name = "Melee Attack"
	base_mana_cost = 0.0  # No mana cost for basic attacks
	base_cast_time = 0.8  # Slower than spark
	tags = ["Melee", "Attack", "Hit"]
	setup_base_stats()

func setup_base_stats() -> void:
	base_stats = {
		"damage": 15.0,  # Base hit damage
		"attack_speed": 1.0,  # Base attack speed multiplier
		"attack_range": 100.0,  # Base attack range
	}
	computed_stats = base_stats.duplicate()

func cast(caster: Node2D) -> void:
	if !caster.has_node("HitBox"):
		return
		
	var hitbox = caster.get_node("HitBox") as Area2D
	var overlapping_areas = hitbox.get_overlapping_areas()
	
	# Get direction to target if it exists
	var attack_direction = Vector2.RIGHT
	if caster.has_method("get_target_direction"):
		attack_direction = caster.get_target_direction()
	
	for area in overlapping_areas:
		var target = area.get_parent()
		if target == caster:
			continue
			
		# Only hit the player
		if !target.is_in_group("player"):
			continue
			
		# Check if target is in attack arc
		var to_target = (target.global_position - caster.global_position).normalized()
		var angle_to_target = abs(attack_direction.angle_to(to_target))
		
		if angle_to_target <= attack_angle/2:
			if target.has_method("take_hit"):
				target.take_hit(computed_stats.damage, "physical") 
