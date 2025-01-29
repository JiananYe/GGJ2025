extends Node2D
class_name MobSpawner

@export var min_spawn_distance: float = 700.0
@export var max_spawn_distance: float = 1100.0
@export var max_distance: float = 2000.0  # Maximum distance before respawning
@export var max_mobs: int = 18
@export var spawn_interval: float = 1  # Time between spawns
@export var initial_spawn_count: int = 10
@export var auto_start: bool = true
@export var boss_scene: PackedScene
@export var melee_mob_scene: PackedScene
@export var ranged_mob_scene: PackedScene
@export var fast_mob_scene: PackedScene
@export var fast_mob_start_time: float = 40.0  # Time when fast mobs start spawning
@export var ranged_mob_start_time: float = 20.0  # Time when ranged mobs start spawning
@export var final_boss_scene: PackedScene
@export var final_boss_start_time: float = 80.0 

var current_mobs: int = 0
var spawn_timer: Timer
var active: bool = false
var player: Node2D

# Optional - define spawn points instead of random area
var spawn_points: Array[Vector2] = []

signal mob_spawned(mob: Node2D)
signal mob_died(mob: Node2D)

func _ready() -> void:
	await get_tree().create_timer(3.2).timeout
	setup_timer()
	# Find the player node
	player = get_tree().get_first_node_in_group("player")
	if !player:
		push_error("Player node not found! Make sure player is in group 'player'")
		return
		
	if auto_start:
		start_spawning()
	
	# Connect to difficulty signal
	GameManager.difficulty_increased.connect(_on_difficulty_increased)
	GameManager.boss_spawn_time.connect(_on_boss_spawn_time)

func setup_timer() -> void:
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = false
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)

func start_spawning() -> void:
	if !player:
		push_error("Cannot start spawning without player reference")
		return
		
	active = true
	# Initial spawn
	for i in initial_spawn_count:
		spawn_mob()
	spawn_timer.start()

func stop_spawning() -> void:
	active = false
	spawn_timer.stop()

func get_random_spawn_position() -> Vector2:
	# Generate random angle
	var angle = randf() * 2 * PI
	
	# Generate random distance between min and max spawn distance
	var distance = randf_range(min_spawn_distance, max_spawn_distance)
	
	# Calculate position relative to player
	var spawn_offset = Vector2(
		cos(angle) * distance,
		sin(angle) * distance
	)
	
	return player.global_position + spawn_offset

func spawn_mob() -> void:
	if current_mobs >= max_mobs:
		return
		
	if !active or !player:
		return
		
	# Choose mob type based on game time
	var mob_scene_to_use
	var available_types = []
	
	# Basic melee mob is always available
	available_types.append({
		"scene": melee_mob_scene,
		"weight": 0.5  # 50% chance when all types available
	})
	
	# Add fast mob after start time
	if GameManager.game_time >= fast_mob_start_time:
		available_types.append({
			"scene": fast_mob_scene,
			"weight": 0.2  # 20% chance when available
		})
	
	# Add ranged mob after start time
	if GameManager.game_time >= ranged_mob_start_time:
		available_types.append({
			"scene": ranged_mob_scene,
			"weight": 0.3  # 30% chance when available
		})
	
	# Calculate total weight
	var total_weight = 0.0
	for type in available_types:
		total_weight += type.weight
	
	# Choose random mob type based on weights
	var rand = randf() * total_weight
	var current_weight = 0.0
	
	for type in available_types:
		current_weight += type.weight
		if rand <= current_weight:
			mob_scene_to_use = type.scene
			break
	
	if !mob_scene_to_use:
		push_error("No mob scene assigned")
		return
		
	var mob = mob_scene_to_use.instantiate() as Node2D
	if !mob:
		push_error("Failed to instantiate mob scene")
		return
		
	# Set mob position
	var spawn_position: Vector2
	if spawn_points.size() > 0:
		spawn_position = spawn_points[randi() % spawn_points.size()]
	else:
		spawn_position = get_random_spawn_position()
	
	mob.global_position = spawn_position
	
	# Scale mob stats with difficulty
	if mob.has_method("apply_difficulty_scaling"):
		mob.apply_difficulty_scaling(GameManager.get_difficulty_multiplier())
	
	# Connect mob signals
	if mob.has_signal("tree_exiting"):
		mob.tree_exiting.connect(_on_mob_died.bind(mob))
	
	add_child(mob)
	current_mobs += 1
	emit_signal("mob_spawned", mob)

func _on_spawn_timer_timeout() -> void:
	spawn_mob()

func _on_mob_died(mob: Node2D) -> void:
	current_mobs -= 1
	emit_signal("mob_died", mob)

# Optional - Add spawn points manually
func add_spawn_point(point: Vector2) -> void:
	spawn_points.append(point)

func clear_spawn_points() -> void:
	spawn_points.clear()

func _on_difficulty_increased(level: int) -> void:
	# Increase spawn rate with difficulty
	spawn_interval = max(0.4, 0.5 - (level * 0.05))  # Decrease interval, minimum 0.2s
	if spawn_timer:
		spawn_timer.wait_time = spawn_interval
	
	# Increase max mobs with difficulty
	max_mobs = max_mobs + (level * 2)  # Add 2 max mobs per difficulty level

func _on_boss_spawn_time() -> void:
	if !player:
		return
		
	if GameManager.game_time >= final_boss_start_time:
		# Spawne Final Boss statt normalen Boss
		var boss = final_boss_scene.instantiate()
		if boss:
			stop_spawning()  # Stoppe andere Mob Spawns
			var spawn_pos = get_random_spawn_position()
			boss.global_position = spawn_pos
			add_child(boss)
			emit_signal("mob_spawned", boss)
			
			# Starte Timer für 10 Sekunden
			await get_tree().create_timer(10.0).timeout
			
			# Starte Spawning wieder, wenn der Boss noch lebt
			if is_instance_valid(boss) and boss.is_inside_tree():
				start_spawning()
	else:
		# Normaler Boss Spawn Code
		var boss = boss_scene.instantiate()
		if boss:
			var spawn_pos = get_random_spawn_position()
			boss.global_position = spawn_pos
			add_child(boss)
			emit_signal("mob_spawned", boss)

func _physics_process(_delta: float) -> void:
	if !player:
		return
		
	# Check all mobs
	for mob in get_tree().get_nodes_in_group("mob"):
		if mob.global_position.distance_to(player.global_position) > max_distance:
			# Get mob type
			var mob_type = "melee"
			if mob is RangedMob:
				mob_type = "ranged"
			elif mob is FastMob:
				mob_type = "fast"
			elif mob is BossMob:
				continue  # Don't respawn bosses
			
			# Remove old mob
			current_mobs -= 1
			mob.queue_free()
			
			# Spawn new mob
			spawn_mob()
