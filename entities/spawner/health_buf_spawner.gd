class_name HealthBuffSpawner
extends Node2D

@export var health_buf_scene: PackedScene = preload("res://entities/health-buf/health_buf.tscn")  # Health buffer scene
@export var spawn_interval: float = 5.0  # Time interval for spawning health buffers
@export var max_spawn_count: int = 1  # Max number of health buffers to be spawned at once

var spawn_timer: Timer

func _ready() -> void:
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = false
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)
	
	# Spawn initial health buffers
	_spawn_health_bufs(max_spawn_count)

# Handle the spawn timer and spawn health buffers
func _on_spawn_timer_timeout() -> void:
	_spawn_health_bufs(1)  # Spawn one health buffer on each timeout

# Function to spawn health buffers at random positions
func _spawn_health_bufs(count: int) -> void:
	for i in range(count):
		var health_buf = health_buf_scene.instantiate()  # Create health buffer instance
		var random_position = Vector2(randf_range(-500, 500), randf_range(-500, 500))  # Random position
		health_buf.position = random_position  # Set the position of the health buffer
		add_child(health_buf)  # Add health buffer to the scene tree
