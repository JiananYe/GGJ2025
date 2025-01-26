extends CanvasLayer

@onready var hp_fill = $HPGlobe/HPFill
@onready var mana_fill = $ManaGlobe/ManaFill
@onready var exp_bar = $ActionBar/ExpBar/ExpFill
@onready var level_label = $ActionBar/ExpBar/LevelLabel
@onready var action_bar = $ActionBar/MarginContainer/HBoxContainer
@onready var hp_tooltip = $HPGlobe/TooltipLabel
@onready var mana_tooltip = $ManaGlobe/TooltipLabel
var slot_map = {}

var player: Node

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	if player:
		player.connect("on_level_up", _on_player_level_up)
	
	for slot in action_bar.get_children():
		if slot is ActionBarSlot:
			var slot_name = slot.name.to_lower().trim_suffix("slot")
			slot_map[slot_name] = slot
			slot.item_equipped.connect(_on_item_equipped)
			slot.item_unequipped.connect(_on_item_unequipped)
	
	# Hide tooltips initially
	hp_tooltip.hide()
	mana_tooltip.hide()

func _process(_delta: float) -> void:
	if !player:
		return
		
	# Update HP globe fill
	var hp_shader = hp_fill.material as ShaderMaterial
	if hp_shader:
		hp_shader.set_shader_parameter("fill_amount", player.current_hp / player.max_hp)
		hp_tooltip.text = "%d / %d HP" % [player.current_hp, player.max_hp]
	
	# Update Mana globe fill
	var mana_shader = mana_fill.material as ShaderMaterial
	if mana_shader:
		mana_shader.set_shader_parameter("fill_amount", player.current_mana / player.max_mana)
		mana_tooltip.text = "%d / %d Mana" % [player.current_mana, player.max_mana]
	
	# Update exp bar
	exp_bar.scale.x = player.experience / player.exp_to_next_level
	level_label.text = "Level %d" % player.level

func _on_player_level_up(new_level: int) -> void:
	level_label.text = "Level %d" % new_level 
	
func _on_item_pickup(item: Item) -> void:
	if !item or !item.base_item:
		return
		
	# Get the appropriate slot based on item type
	var item_type = item.base_item.item_type.to_lower()
	if slot_map.has(item_type):
		var slot = slot_map[item_type]
		if !slot.current_item:  # Only equip if slot is empty
			slot.set_item(item)
			# No need to call _on_item_equipped here as it's called in set_item
		else:
			print("Slot already occupied for item type: ", item_type)
	else:
		push_error("No slot found for item type: " + item_type)

func _on_item_equipped(item: Item) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.equip_item(item)

func _on_item_unequipped(item: Item) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.unequip_item(item)

func _on_hp_globe_mouse_entered() -> void:
	hp_tooltip.show()

func _on_hp_globe_mouse_exited() -> void:
	hp_tooltip.hide()

func _on_mana_globe_mouse_entered() -> void:
	mana_tooltip.show()

func _on_mana_globe_mouse_exited() -> void:
	mana_tooltip.hide()
