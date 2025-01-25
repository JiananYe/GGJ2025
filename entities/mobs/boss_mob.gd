extends Mob
class_name BossMob

enum BossState { IDLE, CHASE, MELEE_ATTACK, PROJECTILE_ATTACK }
var current_boss_state: BossState = BossState.IDLE

var projectile_attack_range: float = 500.0
var projectile_cooldown: float = 3.0
var can_use_projectile: bool = true

func _ready() -> void:
	super._ready()
	# Increase boss stats
	max_hp *= 5.0
	current_hp = max_hp
	movement_speed = 150.0  # Slower but tankier
	experience_value = 200.0  # More exp reward

func setup_skills() -> void:
	super.setup_skills()  # Setup basic melee attack
	
	# Add projectile attack
	var projectile_skill = BossProjectileSkill.new()
	skill_manager.add_skill_link("projectile_attack")
	skill_manager.link_skills("projectile_attack", projectile_skill, [])

func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
	if target:
		handle_boss_combat()
	else:
		find_player()

func handle_boss_combat() -> void:
	if !is_instance_valid(target):
		target = null
		return
		
	var distance = global_position.distance_to(target.global_position)
	direction = (target.global_position - global_position).normalized()
	
	# Update sprite direction
	if has_node("AnimatedSprite2D"):
		var sprite = get_node("AnimatedSprite2D")
		if direction.x != 0:
			sprite.flip_h = direction.x < 0
	
	match current_boss_state:
		BossState.IDLE:
			if distance <= attack_range:
				current_boss_state = BossState.MELEE_ATTACK
			elif distance <= projectile_attack_range and can_use_projectile:
				current_boss_state = BossState.PROJECTILE_ATTACK
			else:
				current_boss_state = BossState.CHASE
		
		BossState.CHASE:
			velocity = direction * movement_speed
			if distance <= attack_range:
				current_boss_state = BossState.MELEE_ATTACK
			elif distance <= projectile_attack_range and can_use_projectile:
				current_boss_state = BossState.PROJECTILE_ATTACK
		
		BossState.MELEE_ATTACK:
			velocity = Vector2.ZERO
			if can_attack:
				melee_attack()
			elif distance > attack_range:
				current_boss_state = BossState.CHASE
		
		BossState.PROJECTILE_ATTACK:
			velocity = Vector2.ZERO
			projectile_attack()
			current_boss_state = BossState.CHASE
	
	move_and_slide()

func melee_attack() -> void:
	can_attack = false
	change_state(PlayerState.ATTACKING)
	skill_manager.use_skill("basic_attack", self)
	
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
	if current_state == PlayerState.ATTACKING:
		change_state(PlayerState.IDLE)

func projectile_attack() -> void:
	if !can_use_projectile:
		return
		
	can_use_projectile = false
	skill_manager.use_skill("projectile_attack", self)
	
	await get_tree().create_timer(projectile_cooldown).timeout
	can_use_projectile = true 
