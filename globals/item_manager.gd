extends Node

var equipment_item_scene = preload("res://entities/items/EquipmentItem.tscn")
var item_generator = ItemGenerator.new()

func drop_random_item(position: Vector2, level: int) -> void:
	var base_item = BaseItemsDB.get_random_base_item()
	var dropped_item = item_generator.generate_item(base_item, level)
	
	var item_node = equipment_item_scene.instantiate()
	item_node.item = dropped_item
	get_tree().current_scene.call_deferred("add_child", item_node)
	item_node.global_position = position
	
	# Drop animation
	item_node.scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(item_node, "scale", Vector2.ONE, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK) 
