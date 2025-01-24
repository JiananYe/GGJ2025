extends CharacterBody2D
class_name Entity

# Base Attributes
var max_hp: float = 100.0
var current_hp: float = max_hp
var max_mana: float = 100.0
var current_mana: float = max_mana
var base_shield: float = 0.0
var current_shield: float = base_shield

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
const ARMOR_EFFECTIVENESS = 0.1  # 10% effectiveness per point
const EVASION_EFFECTIVENESS = 0.05  # 5% per point
const RESISTANCE_CAP = 75.0  # Maximum resistance percentage
const BASE_DAMAGE_REDUCTION = 0.25  # Base damage reduction from armor

func take_hit(damage: float, damage_type: String = "physical") -> float:
	var final_damage = calculate_damage(damage, damage_type)
	apply_damage(final_damage)
	return final_damage

func calculate_damage(incoming_damage: float, damage_type: String) -> float:
	# Start with base damage
	var final_damage = incoming_damage
	
	# Apply resistance based on damage type
	match damage_type:
		"physical":
			# Armor damage reduction formula (similar to PoE)
			var damage_reduction = (armor * ARMOR_EFFECTIVENESS) / (armor * ARMOR_EFFECTIVENESS + BASE_DAMAGE_REDUCTION)
			damage_reduction = min(damage_reduction, 0.9)  # Cap at 90%
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
