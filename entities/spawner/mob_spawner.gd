extends Node2D
class_name MobSpawner

@export var mob_scene: PackedScene
@export var min_spawn_distance: float = 500.0
@export var max_spawn_distance: float = 1000.0
@export var max_mobs: int = 20
@export var spawn_interval: float = 0.5  # Time between spawns
@export var initial_spawn_count: int = 10
@export var auto_start: bool = true

var current_mobs: int = 0
var spawn_timer: Timer
var active: bool = false
var player: Node2D

# Optional - define spawn points instead of random area
var spawn_points: Array[Vector2] = []

signal mob_spawned(mob: Node2D)
signal mob_died(mob: Node2D)

func _ready() -> void:
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
	if !active or !mob_scene or current_mobs >= max_mobs or !player:
		return
		
	var mob = mob_scene.instantiate() as Node2D
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
	spawn_interval = max(0.2, 0.5 - (level * 0.05))  # Decrease interval, minimum 0.2s
	if spawn_timer:
		spawn_timer.wait_time = spawn_interval
	
	# Increase max mobs with difficulty
	max_mobs = 20 + (level * 2)  # Add 2 max mobs per difficulty level
