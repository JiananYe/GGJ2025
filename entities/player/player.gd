extends EntityStateMachine

var hp_bar_scene = preload("res://entities/ui/HPBar.tscn")
@onready var hp_bar: Control

@onready var skill_manager = $SkillManager

var has_cast_skill: bool = false  # Track if we've cast the skill in this attack state

func _ready() -> void:
	add_to_group("player")
	setup_skills()
	# Reset animation speed when changing to non-attack animations
	animated_sprite.animation_finished.connect(_on_animation_finished)

	# Setup HP bar
	hp_bar = hp_bar_scene.instantiate()
	add_child(hp_bar)
	hp_bar.position = Vector2(0, -100)  # Position above entity
	hp_bar.entity = self

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
	var support_skills: Array = [
		additional_projectiles,
		faster_casting,
		increased_duration,
		faster_projectiles,
		projectile_damage
	]
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
	if Input.is_action_just_pressed("attack"):
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

func handle_hurt_state() -> void:
	if !animated_sprite.is_playing():
		change_state(PlayerState.IDLE)

func handle_dying_state() -> void:
	if !animated_sprite.is_playing():
		die()

func die() -> void:
	if current_state != PlayerState.DYING:
		change_state(PlayerState.DYING)
		
	is_dead = true
