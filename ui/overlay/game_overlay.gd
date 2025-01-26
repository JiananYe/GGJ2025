extends CanvasLayer

@onready var hp_fill = $HPGlobe/HPFill
@onready var mana_fill = $ManaGlobe/ManaFill
@onready var exp_bar = $ActionBar/ExpBar/ExpFill
@onready var level_label = $ActionBar/ExpBar/LevelLabel
@onready var action_bar = $ActionBar/MarginContainer/HBoxContainer
@onready var hp_tooltip = $HPGlobe/TooltipLabel
@onready var mana_tooltip = $ManaGlobe/TooltipLabel
@onready var equipment_tooltip = $EquipmentTooltip
@onready var tooltip_text = $EquipmentTooltip/MarginContainer/TooltipText
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
			slot.mouse_entered.connect(_on_slot_mouse_entered.bind(slot))
			slot.mouse_exited.connect(_on_slot_mouse_exited)
	
	# Hide tooltips initially
	hp_tooltip.hide()
	mana_tooltip.hide()
	equipment_tooltip.hide()

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
	# Map "staff" type to "staff" slot
	if item_type == "staff":
		item_type = "staff"
	elif item_type == "body_armor":
		item_type = "bodyarmor"
		
	if slot_map.has(item_type):
		var slot = slot_map[item_type]
		if !slot.current_item:  # Only equip if slot is empty
			slot.set_item(item)
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

func _on_slot_mouse_entered(slot: ActionBarSlot) -> void:
	if slot.current_item:
		var item = slot.current_item
		var tooltip_text_content = "%s\n" % [item.get_display_name()]
		
		# Add base stats if they exist
		for stat in item.base_stats:
			tooltip_text_content += "%s: %s\n" % [stat, str(item.base_stats[stat])]
		
		# Add modifier stats
		if item.prefixes.size() > 0 or item.suffixes.size() > 0:
			tooltip_text_content += "\nModifiers:\n"
			for stat in item.get_modifier_descriptions():
				tooltip_text_content += stat + "\n"
			
		tooltip_text.text = tooltip_text_content
		
		# Wait a frame for the label to resize
		await get_tree().process_frame
		
		# Update panel size based on label size
		var label_size = tooltip_text.size
		equipment_tooltip.custom_minimum_size = label_size + Vector2(16, 16) # Add padding
		equipment_tooltip.size = equipment_tooltip.custom_minimum_size
		
		# Position tooltip above the slot
		var global_pos = slot.global_position
		equipment_tooltip.global_position = Vector2(
			global_pos.x - equipment_tooltip.size.x/2, 
			global_pos.y - equipment_tooltip.size.y - 10
		)
		equipment_tooltip.show()

func _on_slot_mouse_exited() -> void:
	equipment_tooltip.hide()
