extends Mob
class_name FastMob

func _ready() -> void:
	super._ready()
	# Adjust fast mob stats
	max_hp *= 0.6  # Less HP than normal mobs
	current_hp = max_hp
	attack_cooldown = 0.4  # Attack faster
	
	movement_speed = 600.0
	
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp

func setup_skills() -> void:
	# Create melee attack skill
	var melee_attack = MeleeAttackSkill.new()
	melee_attack.base_stats.damage = 15.0  # Less damage but attacks faster
	
	# Setup attack skill
	skill_manager.add_skill_link("basic_attack")
	skill_manager.link_skills("basic_attack", melee_attack, []) 
