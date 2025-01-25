extends CanvasLayer

@onready var hp_fill = $HPGlobe/HPFill
@onready var mana_fill = $ManaGlobe/ManaFill
@onready var exp_bar = $ActionBar/ExpBar/ExpFill
@onready var level_label = $ActionBar/ExpBar/LevelLabel

var player: Node

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	if player:
		player.connect("on_level_up", _on_player_level_up)
	
	# Setup shaders
	var hp_shader = hp_fill.material as ShaderMaterial
	var mana_shader = mana_fill.material as ShaderMaterial
	
	if hp_shader and mana_shader:
		hp_shader.set_shader_parameter("fill_amount", 1.0)
		mana_shader.set_shader_parameter("fill_amount", 1.0)

func _process(_delta: float) -> void:
	if !player:
		return
		
	# Update HP globe fill
	var hp_shader = hp_fill.material as ShaderMaterial
	if hp_shader:
		hp_shader.set_shader_parameter("fill_amount", player.current_hp / player.max_hp)
	
	# Update Mana globe fill
	var mana_shader = mana_fill.material as ShaderMaterial
	if mana_shader:
		mana_shader.set_shader_parameter("fill_amount", player.current_mana / player.max_mana)
	
	# Update exp bar
	exp_bar.scale.x = player.experience / player.exp_to_next_level
	level_label.text = "Level %d" % player.level

func _on_player_level_up(new_level: int) -> void:
	level_label.text = "Level %d" % new_level 
