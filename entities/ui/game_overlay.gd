@onready var action_bar = $ActionBar/MarginContainer/HBoxContainer

func _ready() -> void:
	# Connect to equipment pickup signal
	for slot in action_bar.get_children():
		if slot is ActionBarSlot:
			slot.item_equipped.connect(_on_item_equipped)
			slot.item_unequipped.connect(_on_item_unequipped)

func _on_item_pickup(item: Item) -> void:
	# Find appropriate slot based on item type
	var item_type = item.base_item.item_type.to_lower()
	for slot in action_bar.get_children():
		if slot is ActionBarSlot and !slot.current_item:
			slot.set_item(item)
			break

func _on_item_equipped(item: Item) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.equip_item(item)

func _on_item_unequipped(item: Item) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.unequip_item(item) 