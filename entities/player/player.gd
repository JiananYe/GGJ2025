extends EntityStateMachine

var hp_bar_scene = preload("res://entities/ui/HPBar.tscn")
@onready var hp_bar: Control

@onready var skill_manager = $SkillManager

@onready var event_emitter_walking : AudioStreamPlayer = $Stein2
@onready var event_emitter_attacking : AudioStreamPlayer = $MainCharacterShooting
@onready var event_emitter_get_hit : AudioStreamPlayer = $HitEnemy

var has_cast_skill: bool = false  # Track if we've cast the skill in this attack state

var level_up_particles = preload("res://entities/ui/LevelUpParticles.tscn")
var level_up_text = preload("res://entities/ui/LevelUpText.tscn")

var level_up_selection_scene = preload("res://entities/ui/LevelUpSelection.tscn")
var level_up_selection: Control

# Change the signal name
signal on_level_up(new_level: int)

var equipped_items: Dictionary = {
	"staff": null,
	"helmet": null,
	"body_armor": null,
	"boots": null,
	"belt": null,
	"ring": null,
	"amulet": null,
	"bracers": null
}

# Base stats that will be used when resetting
const BASE_STATS = {
	"max_hp": 100.0,
	"max_mana": 200.0,
	"armor": 0.0,
	"evasion": 0.0,
	"resistance": 0.0,
	"damage_multiplier": 1.0,
	"projectile_damage": 0.0,
	"crit_chance": 5.0,
	"crit_multiplier": 1.5,
	"mana_regeneration_rate": 1.0,
	"cast_speed": 100.0  # Base multiplier of 1.0 (100%)
}

func _ready() -> void:
	super._ready()
	add_to_group("player")
	setup_skills()
	# Reset animation speed when changing to non-attack animations
	animated_sprite.animation_finished.connect(_on_animation_finished)

	# Setup HP bar
	hp_bar = hp_bar_scene.instantiate()
	add_child(hp_bar)
	hp_bar.position = Vector2(-50, -100)  # Position above entity
	hp_bar.entity = self
	
	# Initialize exp system
	exp_to_next_level = get_exp_to_next_level()

	# Setup level up selection in UI layer
	var ui_layer = get_tree().get_first_node_in_group("ui_layer")
	if ui_layer:
		level_up_selection = level_up_selection_scene.instantiate()
		ui_layer.add_child(level_up_selection)
		level_up_selection.skill_selected.connect(_on_skill_selected)
	else:
		push_error("UI Layer not found! Make sure the CanvasLayer is in group 'ui_layer'")


func _on_animation_finished() -> void:
	if current_state != PlayerState.ATTACKING:
		animated_sprite.speed_scale = 1.0
	else:
		event_emitter_attacking.play()

func setup_skills() -> void:
	# Create skills
	var spark = SparkSkill.new()
	var additional_projectiles = AdditionalProjectilesSupport.new()
	var faster_casting = FasterCastingSupport.new()
	var increased_duration = IncreasedDurationSupport.new()
	var faster_projectiles = FasterProjectilesSupport.new()
	var projectile_damage = ProjectileDamageSupport.new()
	
	# Setup primary attack
	skill_manager.add_skill_link("primary_attack")
	var support_skills: Array = []
	skill_manager.link_skills("primary_attack", spark, support_skills)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
	# Handle movement with WASD
	var direction = Vector2.ZERO
	direction.x = Input.get_axis("left", "right")
	direction.y = Input.get_axis("up", "down")
	
	# Normalize diagonal movement
	if direction.length() > 1.0:
		direction = direction.normalized()
	
	velocity = direction * speed
	
	# Update sprite direction
	if direction.x != 0:
		animated_sprite.flip_h = direction.x < 0
	
	# State machine logic
	match current_state:
		PlayerState.IDLE:
			handle_idle_state()
		PlayerState.WALKING:
			handle_walking_state()
		PlayerState.ATTACKING:
			handle_attacking_state()
		PlayerState.HURT:
			handle_hurt_state()
		PlayerState.DYING:
			handle_dying_state()
	
	move_and_slide()


func handle_idle_state() -> void:
	if Input.is_action_pressed("attack"):
		change_state(PlayerState.ATTACKING)
	elif velocity.length() > 0:
		change_state(PlayerState.WALKING)
		

func handle_walking_state() -> void:
	if Input.is_action_just_pressed("attack"):
		change_state(PlayerState.ATTACKING)
	elif velocity.length() == 0:
		change_state(PlayerState.IDLE)

func handle_attacking_state() -> void:
	if !has_cast_skill:
		# Cast spark only once when entering attack state
		skill_manager.use_skill("primary_attack", self)
		has_cast_skill = true
	
	if !animated_sprite.is_playing():
		has_cast_skill = false
		animated_sprite.speed_scale = 1.0  # Reset speed scale
		change_state(PlayerState.IDLE)

func heal(amount: float) -> void:
	current_hp = min(current_hp + amount, max_hp)

func handle_hurt_state() -> void:
	if !animated_sprite.is_playing():
		change_state(PlayerState.IDLE)

func handle_dying_state() -> void:
	if !animated_sprite.is_playing():
		die()

func die() -> void:
	if is_dead:
		return
	
	if current_state != PlayerState.DYING:
		change_state(PlayerState.DYING)
		
	is_dead = true
	DirtyDirtyUiManager.main_menu.trigger_death_menu()

func level_up() -> void:
	super.level_up()
	
	# Send exp to passive tree
	var passive_tree = get_tree().get_first_node_in_group("passive_tree")
	if passive_tree:
		passive_tree.add_ascension_exp(exp_to_next_level)
	
	# Increase player stats with level
	max_hp += 2.0
	current_hp = max_hp
	max_mana += 2.0
	current_mana = max_mana
	
	# Spawn level up effects
	spawn_level_up_effects()
	
	# Show skill selection
	level_up_selection.show_selection()
	
	# Emit level up signal
	emit_signal("on_level_up", level)

func spawn_level_up_effects() -> void:
	# Spawn particles
	var particles = level_up_particles.instantiate()
	add_child(particles)
	particles.emitting = true
	
	# Spawn level up text
	var text = level_up_text.instantiate()
	get_tree().current_scene.add_child(text)
	text.global_position = global_position + Vector2(0, -100)
	
	# Optional: Add screen shake or other effects
	if has_node("Camera2D"):
		var camera = get_node("Camera2D")
		var tween = create_tween()
		tween.tween_property(camera, "zoom", Vector2(1.1, 1.1), 0.1)
		tween.tween_property(camera, "zoom", Vector2(1.0, 1.0), 0.1)

func _on_skill_selected(skill_data: Dictionary) -> void:
	# Create and add the selected skill
	var skill_class = load("res://entities/skills/support/" + skill_data.skill.to_snake_case() + ".gd")
	if skill_class:
		var new_skill = skill_class.new()
		var main_skill = skill_manager.get_main_skill("primary_attack")
		var current_supports = skill_manager.get_support_skills("primary_attack")
		
		if main_skill:
			skill_manager.link_skills("primary_attack", main_skill, current_supports + [new_skill])

func equip_item(item: Item) -> void:
	var slot = item.base_item.item_type.to_lower()
	
	# Unequip existing item
	if equipped_items[slot]:
		unequip_item(equipped_items[slot])
	
	equipped_items[slot] = item
	apply_item_stats(item)

func unequip_item(item: Item) -> void:
	var slot = item.base_item.item_type.to_lower()
	equipped_items[slot] = null
	remove_item_stats(item)

func apply_item_stats(item: Item) -> void:
	# Apply base stats
	for stat_name in item.base_stats:
		match stat_name:
			"physical_damage":
				attack_damage += item.base_stats[stat_name]
			"spell_damage":
				spell_damage += item.base_stats[stat_name]
			"armor":
				armor += item.base_stats[stat_name]
			"hp_bonus":
				max_hp += item.base_stats[stat_name]
				current_hp += item.base_stats[stat_name]
			"mana_bonus":
				max_mana += item.base_stats[stat_name]
				current_mana += item.base_stats[stat_name]
			"movement_speed":
				speed += item.base_stats[stat_name]
	
	# Apply modifiers
	for mod in item.prefixes + item.suffixes:
		match mod.name:
			"Adds {0} Physical Damage":
				attack_damage += mod.values[0]
			"{0}% Increased Spell Damage":
				spell_damage += mod.values[0]
			"{0}% Increased Armor":
				armor += (armor * mod.values[0] / 100.0)
			"+{0} to Maximum Life":
				max_hp += mod.values[0]
				current_hp += mod.values[0]
			"+{0} to Maximum Mana":
				max_mana += mod.values[0]
				current_mana += mod.values[0]
			"{0}% Increased Movement Speed":
				speed += (speed * mod.values[0] / 100.0)
			"{0}% Increased Cast Speed":
				cast_speed += mod.values[0]
			"{0}% Increased Critical Strike Chance":
				crit_chance += mod.values[0]
			"+{0} to All Attributes":
				# Assuming attributes affect multiple stats
				max_hp += mod.values[0] * 2
				current_hp += mod.values[0] * 2
				max_mana += mod.values[0] * 2
				current_mana += mod.values[0] * 2
				attack_damage += mod.values[0]
				spell_damage += mod.values[0]

func remove_item_stats(item: Item) -> void:
	# Remove base stats
	for stat_name in item.base_stats:
		match stat_name:
			"physical_damage":
				attack_damage -= item.base_stats[stat_name]
			"spell_damage":
				spell_damage -= item.base_stats[stat_name]
			"armor":
				armor -= item.base_stats[stat_name]
			"hp_bonus":
				max_hp -= item.base_stats[stat_name]
				current_hp = min(current_hp, max_hp)
			"mana_bonus":
				max_mana -= item.base_stats[stat_name]
				current_mana = min(current_mana, max_mana)
			"movement_speed":
				speed -= item.base_stats[stat_name]
	
	# Remove modifiers
	for mod in item.prefixes + item.suffixes:
		match mod.name:
			"Adds {0} Physical Damage":
				attack_damage -= mod.values[0]
			"{0}% Increased Spell Damage":
				spell_damage -= mod.values[0]
			"{0}% Increased Armor":
				armor -= (armor * mod.values[0] / 100.0)
			"+{0} to Maximum Life":
				max_hp -= mod.values[0]
				current_hp = min(current_hp, max_hp)
			"+{0} to Maximum Mana":
				max_mana -= mod.values[0]
				current_mana = min(current_mana, max_mana)
			"{0}% Increased Movement Speed":
				speed -= (speed * mod.values[0] / 100.0)
			"{0}% Increased Cast Speed":
				cast_speed -= mod.values[0]
			"{0}% Increased Critical Strike Chance":
				crit_chance -= mod.values[0]
			"+{0} to All Attributes":
				max_hp -= mod.values[0] * 2
				current_hp = min(current_hp, max_hp)
				max_mana -= mod.values[0] * 2
				current_mana = min(current_mana, max_mana)
				attack_damage -= mod.values[0]
				spell_damage -= mod.values[0]

func is_equipment_slot_empty(slot: String) -> bool:
	return equipped_items[slot] == null

func reset_to_base_stats() -> void:
	max_hp = BASE_STATS.max_hp
	max_mana = BASE_STATS.max_mana
	armor = BASE_STATS.armor
	evasion = BASE_STATS.evasion
	resistance = BASE_STATS.resistance
	damage_multiplier = BASE_STATS.damage_multiplier
	projectile_damage = BASE_STATS.projectile_damage
	crit_chance = BASE_STATS.crit_chance
	crit_multiplier = BASE_STATS.crit_multiplier
	mana_regeneration_rate = BASE_STATS.mana_regeneration_rate
	cast_speed = BASE_STATS.cast_speed
	
	# Set current values
	current_hp = max_hp
	current_mana = max_mana
