extends EntityStateMachine

var hp_bar_scene = preload("res://entities/ui/HPBar.tscn")
@onready var hp_bar: Control

@onready var skill_manager = $SkillManager

var has_cast_skill: bool = false  # Track if we've cast the skill in this attack state

var level_up_particles = preload("res://entities/ui/LevelUpParticles.tscn")
var level_up_text = preload("res://entities/ui/LevelUpText.tscn")

var level_up_selection_scene = preload("res://entities/ui/LevelUpSelection.tscn")
var level_up_selection: Control

# Change the signal name
signal on_level_up(new_level: int)

var equipped_items: Dictionary = {
	"weapon": null,
	"helmet": null,
	"body": null,
	"boots": null,
	"ring": null,
	"amulet": null
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
	hp_bar.position = Vector2(0, -100)  # Position above entity
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
	
	velocity = direction * SPEED
	
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

func increase_health(increase) -> void:
	if !animated_sprite.is_playing():
		current_hp += increase
		
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

# Override level_up to emit signal and handle player-specific bonuses
func level_up() -> void:
	super.level_up()
	
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
	for stat_name in item.base_item.base_stats:
		match stat_name:
			"physical_damage":
				attack_damage += item.base_item.base_stats[stat_name].y
			"spell_damage":
				spell_damage += item.base_item.base_stats[stat_name].y
			"armor":
				armor += item.base_item.base_stats[stat_name].y
			# Add more stats as needed
	
	# Apply modifiers
	for mod in item.prefixes + item.suffixes:
		for i in range(mod.values.size()):
			match mod.name:
				"Adds ({0}-{1}) Physical Damage":
					attack_damage += mod.values[i]
				"({0}-{1})% Increased Spell Damage":
					spell_damage += mod.values[i]
				# Add more modifier types as needed

func remove_item_stats(item: Item) -> void:
	# Remove base stats
	for stat_name in item.base_item.base_stats:
		match stat_name:
			"physical_damage":
				attack_damage -= item.base_item.base_stats[stat_name].y
			"spell_damage":
				spell_damage -= item.base_item.base_stats[stat_name].y
			"armor":
				armor -= item.base_item.base_stats[stat_name].y
	
	# Remove modifiers
	for mod in item.prefixes + item.suffixes:
		for i in range(mod.values.size()):
			match mod.name:
				"Adds ({0}-{1}) Physical Damage":
					attack_damage -= mod.values[i]
				"({0}-{1})% Increased Spell Damage":
					spell_damage -= mod.values[i]
