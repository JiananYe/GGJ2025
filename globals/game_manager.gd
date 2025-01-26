extends Node

signal difficulty_increased(level: int)
signal boss_spawn_time

var game_time: float = 0.0
var difficulty_level: int = 0
var difficulty_interval: float = 20.0  # Increase difficulty every 20 seconds
var boss_spawn_interval: float = 20.0  # Changed to 40 seconds
var last_boss_spawn_time: float = 0.0  # Track when last boss spawned

var difficulty_popup_scene = preload("res://ui/difficulty_popup/DifficultyPopup.tscn")
var current_popup: Control

func reset() -> void:
	game_time = 0
	difficulty_level = 0
	difficulty_interval = 20.0
	boss_spawn_interval = 20.0
	last_boss_spawn_time = 0.0

func _ready() -> void:
	# Create the popup
	current_popup = difficulty_popup_scene.instantiate()
	# Wait for the scene tree to be ready
	get_tree().root.ready.connect(func():
		var ui_layer = get_tree().get_first_node_in_group("ui_layer")
		if ui_layer:
			ui_layer.add_child(current_popup)
		else:
			push_error("UI Layer not found for difficulty popup!")
	)

func _process(delta: float) -> void:
	game_time += delta
	
	# Check for difficulty increase
	var new_level = floor(game_time / difficulty_interval)
	if new_level > difficulty_level:
		difficulty_level = new_level
		print("diff increased", difficulty_level)
		emit_signal("difficulty_increased", difficulty_level)
		if current_popup:
			current_popup.show_difficulty(difficulty_level)
	
	# Check for boss spawn
	if game_time - last_boss_spawn_time >= boss_spawn_interval:
		last_boss_spawn_time = game_time
		emit_signal("boss_spawn_time")

# Get multiplier for mob stats based on current difficulty
func get_difficulty_multiplier() -> float:
	return 1.0 + (difficulty_level * 0.2)  # 20% increase per level

# Get experience multiplier based on current difficulty
func get_exp_multiplier() -> float:
	return 1.0 + (difficulty_level * 0.1)  # 10% increase per level 
