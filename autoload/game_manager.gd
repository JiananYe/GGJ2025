extends Node

signal difficulty_increased(level: int)

var game_time: float = 0.0
var difficulty_level: int = 0
var difficulty_interval: float = 60.0  # Increase difficulty every minute

func _process(delta: float) -> void:
	game_time += delta
	
	# Check for difficulty increase
	var new_level = floor(game_time / difficulty_interval)
	if new_level > difficulty_level:
		difficulty_level = new_level
		emit_signal("difficulty_increased", difficulty_level)

# Get multiplier for mob stats based on current difficulty
func get_difficulty_multiplier() -> float:
	return 1.0 + (difficulty_level * 0.2)  # 20% increase per level

# Get experience multiplier based on current difficulty
func get_exp_multiplier() -> float:
	return 1.0 + (difficulty_level * 0.5)  # 50% increase per level 