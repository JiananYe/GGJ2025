extends Panel
class_name ActionBarSlot

signal item_equipped(item: Item)
signal item_unequipped(item: Item)

@onready var item_icon: TextureRect = $ItemIcon
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
			emit_signal("item_equipped", item)
	else:
		item_icon.texture = null
		item_icon.hide()

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("right") and current_item:
		emit_signal("item_unequipped", current_item)
		set_item(null)
