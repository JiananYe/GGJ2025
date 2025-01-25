extends EntityStateMachine
class_name Mob

var hp_bar_scene = preload("res://entities/ui/HPBar.tscn")
@onready var hp_bar: Control

@export var movement_speed: float = 200.0
@export var detection_range: float = 1000.0
@export var min_distance: float = 100.0  # Minimum distance to keep from player

var target: Node2D = null
var direction: Vector2 = Vector2.ZERO

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	super._ready()
	# Try to find player
	find_player()
	
	# Setup HP bar
	hp_bar = hp_bar_scene.instantiate()
	add_child(hp_bar)
	hp_bar.position = Vector2(0, -100)  # Position above entity
	hp_bar.entity = self

func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
	if target:
		chase_target(delta)
	else:
		find_player()

func find_player() -> void:
	target = get_tree().get_first_node_in_group("player")

func chase_target(delta: float) -> void:
	if !is_instance_valid(target):
		target = null
		return
		
	var distance = global_position.distance_to(target.global_position)
	
	# Only chase if within detection range and further than minimum distance
	if distance < detection_range and distance > min_distance:
		# Calculate direction to player
		direction = (target.global_position - global_position).normalized()
		
		# Move towards player
		velocity = direction * movement_speed
		
		# Update sprite direction
		if has_node("AnimatedSprite2D"):
			var sprite = get_node("AnimatedSprite2D")
			if direction.x != 0:
				sprite.flip_h = direction.x < 0
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()

func take_hit(damage: float, damage_type: String = "physical") -> float:
	var final_damage = super.take_hit(damage, damage_type)
	
	var is_crit = randf() < (crit_chance / 100.0)
	if is_crit:
		final_damage *= crit_multiplier
		
	apply_damage(final_damage)
	# Spawn damage number
	var damage_number = damage_number_scene.instantiate()
	get_tree().current_scene.add_child(damage_number)
	damage_number.global_position = global_position + Vector2(0, -50)
	
	damage_number.setup(final_damage, is_crit)
	
	if current_hp <= 0:
		die()
	
	return final_damage

func die() -> void:
	if current_state != PlayerState.DYING:
		change_state(PlayerState.DYING)
		is_dead = true
		# Disable collision
		collision_shape.set_deferred("disabled", true)
		# Make player semi-transparent
		modulate.a = 0.5
		# Disable processing
		set_physics_process(false)
		# Optional: emit signal for game over handling
		# emit_signal("player_died")
