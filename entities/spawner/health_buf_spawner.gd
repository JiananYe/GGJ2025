class_name HealthBuffSpawner
extends Node2D

@export var health_buf_scene: PackedScene = preload("res://entities/health-buf/health_buf.tscn")  # Health buffer scene
@export var spawn_interval: float = 10.0  # Time interval for spawning health buffers
@export var max_spawn_count: int = 3  # Erhöht für besseres Gameplay
@export var spawn_radius: float = 600.0  # Radius für Spawn-Bereich

var spawn_timer: Timer
var current_health_bufs: int = 0

func _ready() -> void:
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = false
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)
	
	# Start the timer
	spawn_timer.start()
	
	# Spawn initial health buffers
	_spawn_health_bufs(1)

# Handle the spawn timer and spawn health buffers
func _on_spawn_timer_timeout() -> void:
	if current_health_bufs < max_spawn_count:
		_spawn_health_bufs(1)

# Function to spawn health buffers at random positions
func _spawn_health_bufs(count: int) -> void:
	for i in range(count):
		if current_health_bufs >= max_spawn_count:
			return
			
		var health_buf = health_buf_scene.instantiate()
		var random_angle = randf() * 2 * PI
		var random_distance = randf() * spawn_radius
		var random_position = Vector2(
			cos(random_angle) * random_distance,
			sin(random_angle) * random_distance
		)
		
		health_buf.position = random_position
		health_buf.tree_exited.connect(_on_health_buf_removed)
		add_child(health_buf)
		current_health_bufs += 1

func _on_health_buf_removed() -> void:
	current_health_bufs -= 1
