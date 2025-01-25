extends Control

@onready var exp_bar: ProgressBar = $ExpBar
@onready var level_label: Label = $LevelLabel

var player: Node

func _ready() -> void:
	if not player:
		return
		
	if player.has_signal("on_level_up"):
		player.on_level_up.connect(_on_player_level_up)
	
	update_display()

func _process(_delta: float) -> void:
	if not player:
		return
		
	update_display()

func update_display() -> void:
	exp_bar.max_value = player.exp_to_next_level
	exp_bar.value = player.experience
	level_label.text = "Level %d" % player.level

func _on_player_level_up(new_level: int) -> void:
	# Optional: Add level up animation or effect here
	pass 