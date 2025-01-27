extends CharacterBody2D
class_name Entity

var damage_number_scene = preload("res://entities/ui/DamageNumber.tscn")
var last_damage_number_position: Vector2 = Vector2.ZERO
var damage_number_count: int = 0
const DAMAGE_NUMBER_RESET_TIME: float = 0.5  # Reset position after this time
var last_damage_time: float = 0.0

# Base Attributes
var max_hp: float = 100.0
var current_hp: float = max_hp
var max_mana: float = 200.0
var current_mana: float = max_mana
var base_shield: float = 0.0
var current_shield: float = base_shield

# Cast Attributes
var cast_speed: float = 100.0  # Base 100% cast speed
var cast_speed_multiplier: float = 1.0  # For modifiers that increase cast speed

# Mana Attributes
var mana_regeneration_rate: float = 10.0  # Base 10% per second
var mana_regeneration_multiplier: float = 1.0  # For modifiers that increase mana regen
var last_mana_spent_time: float = 0.0
var mana_regen_delay: float = 0.5  # Delay in seconds before mana starts regenerating

# Defensive Attributes
var armor: float = 0.0
var evasion: float = 0.0
var resistance: float = 0.0
var elemental_resistances = {
	"fire": 0.0,
	"cold": 0.0,
	"lightning": 0.0
}
var chaos_resistance: float = 0.0

# Offensive Attributes
var damage_multiplier: float = 1.0  # Damage %
var elemental_damage: float = 0.0
var spell_damage: float = 0.0
var projectile_damage: float = 0.0
var attack_damage: float = 0.0

# Utility Attributes
var luck: float = 0.0  # Affects item drops and rare procs
var rarity_find: float = 0.0  # Magic find
var crit_chance: float = 5.0  # Base 5% crit chance
var crit_multiplier: float = 1.5  # Base 150% crit damage

# Combat Constants
const ARMOR_EFFECTIVENESS = 0.1  # 10% effectiveness per point (reduziert von 20%)
const EVASION_EFFECTIVENESS = 0.05  # 5% per point
const RESISTANCE_CAP = 75.0  # Maximum resistance percentage
const BASE_DAMAGE_REDUCTION = 1.0  # Base damage reduction factor (erhöht von 0.5)
const MAX_ARMOR_REDUCTION = 0.75  # Maximum damage reduction from armor (75% statt 90%)

# Experience Attributes
var experience: float = 0.0  # Current exp
var experience_value: float = 0.0  # Exp given when killed
var level: int = 1
var exp_to_next_level: float = 100.0

func _ready() -> void:
	# Initialize current values
	current_hp = max_hp
	current_mana = max_mana

func _process(delta: float) -> void:
	handle_mana_regeneration(delta)

func handle_mana_regeneration(delta: float) -> void:
	# Check if enough time has passed since last mana spent
	if Time.get_unix_time_from_system() - last_mana_spent_time < mana_regen_delay:
		return
		
	# Calculate mana regeneration for this frame
	var regen_amount = (max_mana * (mana_regeneration_rate / 100.0) * mana_regeneration_multiplier) * delta
	
	# Apply regeneration
	if current_mana < max_mana:
		current_mana = min(current_mana + regen_amount, max_mana)

func spend_mana(amount: float) -> bool:
	if current_mana >= amount:
		current_mana -= amount
		last_mana_spent_time = Time.get_unix_time_from_system()
		return true
	return false

func take_hit(damage: float, damage_type: String = "physical") -> float:
	var final_damage = calculate_damage(damage, damage_type)
	
	# Check if it's a critical hit
	var is_crit = randf() < (crit_chance / 100.0)
	if is_crit:
		final_damage *= crit_multiplier
	
	apply_damage(final_damage)
	
	# Spawn damage number with offset
	var current_time = Time.get_unix_time_from_system()
	if current_time - last_damage_time > DAMAGE_NUMBER_RESET_TIME:
		damage_number_count = 0
		last_damage_number_position = Vector2.ZERO
	
	var damage_number = damage_number_scene.instantiate()
	get_tree().current_scene.add_child(damage_number)
	
	# Calculate offset position
	var base_position = global_position + Vector2(0, -50)
	var offset = Vector2(
		randf_range(-20, 20),  # Random X offset
		-damage_number_count * 30  # Stack vertically
	)
	
	damage_number.global_position = base_position + offset
	damage_number.setup(final_damage, is_crit)
	
	# Update tracking variables
	last_damage_number_position = offset
	damage_number_count += 1
	last_damage_time = current_time
	
	return final_damage

func calculate_damage(incoming_damage: float, damage_type: String) -> float:
	# Start with base damage
	var final_damage = incoming_damage
	
	# Apply resistance based on damage type
	match damage_type:
		"physical":
			# Abgeschwächte Rüstungsformel:
			# Schadenreduzierung = (Rüstung * Effektivität) / (Rüstung * Effektivität + Basisfaktor)
			var armor_factor = armor * ARMOR_EFFECTIVENESS
			var damage_reduction = armor_factor / (armor_factor + BASE_DAMAGE_REDUCTION)
			
			# Niedrigere maximale Schadensreduzierung (75%)
			damage_reduction = min(damage_reduction, MAX_ARMOR_REDUCTION)
			
			final_damage *= (1.0 - damage_reduction)
			
		"fire", "cold", "lightning":
			var resistance = elemental_resistances[damage_type]
			resistance = min(resistance, RESISTANCE_CAP)
			final_damage *= (1.0 - (resistance / 100.0))
			
		"chaos":
			var resistance = min(chaos_resistance, RESISTANCE_CAP)
			final_damage *= (1.0 - (resistance / 100.0))
	
	# Apply evasion chance
	if randf() < (evasion * EVASION_EFFECTIVENESS):
		final_damage = 0.0
		
	return final_damage

func apply_damage(damage: float) -> void:
	# First apply damage to shield
	var remaining_damage = damage
	if current_shield > 0:
		if current_shield >= remaining_damage:
			current_shield -= remaining_damage
			remaining_damage = 0
		else:
			remaining_damage -= current_shield
			current_shield = 0
	
	# Then apply remaining damage to HP
	if remaining_damage > 0:
		current_hp = max(0, current_hp - remaining_damage)
		if current_hp <= 0:
			die()

func calculate_outgoing_damage(base_damage: float, damage_type: String) -> float:
	var final_damage = base_damage
	
	# Apply general damage multiplier
	final_damage *= damage_multiplier
	
	# Apply specific damage type multipliers
	match damage_type:
		"spell":
			final_damage *= (1.0 + spell_damage / 100.0)
		"projectile":
			final_damage *= (1.0 + projectile_damage / 100.0)
		"attack":
			final_damage *= (1.0 + attack_damage / 100.0)
		"elemental":
			final_damage *= (1.0 + elemental_damage / 100.0)
	
	# Apply critical strike
	if randf() < (crit_chance / 100.0):
		final_damage *= crit_multiplier
	
	return final_damage

func heal(amount: float) -> void:
	current_hp = min(current_hp + amount, max_hp)

func restore_mana(amount: float) -> void:
	current_mana = min(current_mana + amount, max_mana)

func restore_shield(amount: float) -> void:
	current_shield = min(current_shield + amount, base_shield)

func is_alive() -> bool:
	return current_hp > 0

func die() -> void:
	# Override this in child classes
	pass

func modify_mana_regen(modifier: float) -> void:
	mana_regeneration_multiplier *= (1.0 + modifier / 100.0)

func set_mana_regen_delay(delay: float) -> void:
	mana_regen_delay = delay

func get_total_cast_speed() -> float:
	return (cast_speed / 100.0) * cast_speed_multiplier

func modify_cast_speed(modifier: float) -> void:
	cast_speed_multiplier *= (1.0 + modifier / 100.0)

func get_exp_to_next_level() -> float:
	# Experience curve: each level requires 50% more exp
	return 100.0 * pow(1.1, level - 1)

func gain_experience(amount: float) -> void:
	experience += amount
	
	print("exp gained", amount)
	print("exp total", experience)
	
	while experience >= exp_to_next_level:
		level_up()

func level_up() -> void:
	experience -= exp_to_next_level
	level += 1
	exp_to_next_level = get_exp_to_next_level()
	# Override in child classes for specific level up behavior
