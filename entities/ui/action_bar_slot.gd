extends Panel
class_name ActionBarSlot

signal item_equipped(item: Item)
signal item_unequipped(item: Item)

@onready var item_icon: TextureRect = $ItemIcon
@onready var hover_tooltip = $HoverTooltip
@onready var background = $Background

var current_item: Item = null

func set_item(item: Item) -> void:
	current_item = item
	if item and item.base_item:
		var texture_path = "res://entities/items/assets/%s.png" % item.base_item.item_type.to_lower()
		var texture = load(texture_path)
		if texture:
			item_icon.texture = texture
			item_icon.show()
			setup_tooltip()
			emit_signal("item_equipped", item)
	else:
		item_icon.texture = null
		item_icon.hide()
		hover_tooltip.hide()

func setup_tooltip() -> void:
	if !current_item:
		return
		
	var tooltip_text = "[center]%s[/center]\n" % current_item.get_display_name()
	
	# Add modifiers
	for mod in current_item.prefixes:
		tooltip_text += mod.text + "\n"
	for mod in current_item.suffixes:
		tooltip_text += mod.text + "\n"
		
	hover_tooltip.text = tooltip_text

func _on_mouse_entered() -> void:
	if current_item:
		hover_tooltip.show()

func _on_mouse_exited() -> void:
	hover_tooltip.hide()

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("right") and current_item:
		emit_signal("item_unequipped", current_item)
		set_item(null)
