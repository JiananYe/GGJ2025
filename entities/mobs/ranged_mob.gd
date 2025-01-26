extends Mob
class_name RangedMob

var projectile_attack_range: float = 400.0
var projectile_cooldown: float = 2.0
var can_use_projectile: bool = true

func _ready() -> void:
	super._ready()
	# Adjust ranged mob stats
	max_hp *= 0.8  # Slightly less HP than melee mobs
	current_hp = max_hp
	movement_speed = 150.0  # Slower than melee mobs
	min_distance = 250.0  # Try to maintain distance for ranged attacks
	attack_range = projectile_attack_range
	
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp

func setup_skills() -> void:
	# Only use projectile attack
	var projectile_skill = BossProjectileSkill.new()
	skill_manager.add_skill_link("projectile_attack")
	skill_manager.link_skills("projectile_attack", projectile_skill, [])

func attack() -> void:
	if !can_attack:
		return
		
	can_attack = false
	change_state(PlayerState.ATTACKING)
	skill_manager.use_skill("projectile_attack", self)
	
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
	if current_state == PlayerState.ATTACKING:
		change_state(PlayerState.IDLE) 
