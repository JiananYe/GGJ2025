extends Node

signal difficulty_increased(level: int)
signal boss_spawn_time

var game_time: float = 0.0
var difficulty_level: int = 0
var difficulty_interval: float = 20.0  # Increase difficulty every 20 seconds
var boss_spawn_interval: float = 30.0  # Changed to 40 seconds
var last_boss_spawn_time: float = 0.0  # Track when last boss spawned
var difficulty_multiplier: float = 1.0

var difficulty_popup = preload("res://entities/ui/DifficultyPopup.tscn")

func reset() -> void:
	game_time = 0
	difficulty_level = 0
	difficulty_interval = 20.0
	boss_spawn_interval = 20.0
	last_boss_spawn_time = 0.0

func _process(delta: float) -> void:
	game_time += delta
	
	# Check for difficulty increase
	var new_level = floor(game_time / difficulty_interval)
	if new_level > difficulty_level:
		difficulty_level = new_level

		var ui_layer = get_tree().get_first_node_in_group("ui_layer")
		if ui_layer:
			var popup = difficulty_popup.instantiate()
			popup.setup(difficulty_level)  # Pass the current difficulty level
			ui_layer.add_child(popup)

		emit_signal("difficulty_increased", difficulty_level)

	# Check for boss spawn
	if game_time - last_boss_spawn_time >= boss_spawn_interval:
		last_boss_spawn_time = game_time
		emit_signal("boss_spawn_time")

# Get multiplier for mob stats based on current difficulty
func get_difficulty_multiplier() -> float:
	return 1.0 + (difficulty_level * 0.1)  # 20% increase per level

# Get experience multiplier based on current difficulty
func get_exp_multiplier() -> float:
	return 1.0 + (difficulty_level * 0.1)  # 10% increase per level 
