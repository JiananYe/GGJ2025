extends EntityStateMachine
class_name Mob

var hp_bar_scene = preload("res://entities/ui/HPBar.tscn")
@onready var hp_bar: ProgressBar

@onready var skill_manager = $SkillManager

@export var movement_speed: float = 200.0
@export var detection_range: float = 1200.0
@export var min_distance: float = 80.0  # Reduced to allow melee attacks
@export var attack_range: float = 100.0  # Range at which mob will try to attack

var target: Node2D = null
var direction: Vector2 = Vector2.ZERO
var can_attack: bool = true
var attack_cooldown: float = 1.0  # Time between attacks

@onready var movement_collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hit_box_collision_shape: CollisionShape2D = $HitBox/CollisionShape2D

@onready var event_get_hit : = $HitEnemy3

func _ready() -> void:
	super._ready()
	find_player()
	setup_skills()
	
	# Setup HP bar
	hp_bar = hp_bar_scene.instantiate()
	add_child(hp_bar)
	hp_bar.position = Vector2(-50, -100)
	hp_bar.entity = self
	
	# Set base experience value
	experience_value = 5.0
	
	# Apply initial difficulty scaling
	apply_difficulty_scaling(GameManager.get_difficulty_multiplier())

	
func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
	if target:
		handle_combat()
	else:
		find_player()

func find_player() -> void:
	target = get_tree().get_first_node_in_group("player")

func handle_combat() -> void:
	if !is_instance_valid(target):
		target = null
		return
		
	var distance = global_position.distance_to(target.global_position)
	
	if distance < detection_range:
		# Calculate direction to player
		direction = (target.global_position - global_position).normalized()
		
		# Update sprite direction
		if has_node("AnimatedSprite2D"):
			var sprite = get_node("AnimatedSprite2D")
			if direction.x != 0:
				sprite.flip_h = direction.x < 0
		
		if distance <= attack_range and can_attack:
			# Attack if in range
			attack()
		elif distance > min_distance:
			# Move towards player if too far
			velocity = direction * movement_speed
		else:
			velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()

func setup_skills() -> void:
	# Create melee attack skill
	var melee_attack = MeleeAttackSkill.new()
	
	# Setup attack skill
	skill_manager.add_skill_link("basic_attack")
	skill_manager.link_skills("basic_attack", melee_attack, [])

func attack() -> void:
	can_attack = false
	change_state(PlayerState.ATTACKING)
	skill_manager.use_skill("basic_attack", self)
	
	# Start attack cooldown
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
	if current_state == PlayerState.ATTACKING:
		change_state(PlayerState.IDLE)

func get_target_direction() -> Vector2:
	return direction

func take_hit(damage: float, damage_type: String = "physical") -> float:
	event_get_hit.play()
	var final_damage = super.take_hit(damage, damage_type)
	
	if current_hp <= 0:
		die()
	
	return final_damage

func die() -> void:
	if current_state != PlayerState.DYING:
		change_state(PlayerState.DYING)
		
		is_dead = true
		# Give experience to player if killed by player
		var player = get_tree().get_first_node_in_group("player")
		if player and player.has_method("gain_experience"):
			player.gain_experience(experience_value)
		
		# Disable collision
		movement_collision_shape.set_deferred("disabled", true)
		hit_box_collision_shape.set_deferred("disabled", true)
		# Make mob semi-transparent
		modulate.a = 0.5
		# Disable processing
		set_physics_process(false)
		
		# Start despawn timer
		var despawn_timer = get_tree().create_timer(3.0)
		despawn_timer.timeout.connect(func(): queue_free())
		
		# Chance to drop item
		if randf() < 0.05:  # 30% chance to drop item
			drop_random_item()

func apply_difficulty_scaling(multiplier: float) -> void:
	# Scale mob stats
	max_hp *= multiplier
	current_hp = max_hp
	
	# Scale damage with a slightly lower factor to avoid one-shots at high difficulty
	var damage_multiplier = 1.0 + (multiplier - 1.0) * 0.75  # 75% der Schwierigkeitsskalierung
	
	# Scale damage for all skills
	if skill_manager:
		for skill_name in skill_manager.skill_links:
			var skill = skill_manager.get_main_skill(skill_name)
			if skill:
				# Skaliere den Basis- und berechneten Schaden
				if "damage" in skill.base_stats:
					skill.base_stats.damage *= damage_multiplier
					skill.computed_stats.damage *= damage_multiplier
	
	# Scale experience value with both difficulty and a random factor
	var base_exp = experience_value
	experience_value = base_exp * GameManager.get_exp_multiplier()
	
	if hp_bar:
		hp_bar.max_value = max_hp
		hp_bar.value = current_hp

func drop_random_item() -> void:
	ItemManager.drop_random_item(global_position, level)
