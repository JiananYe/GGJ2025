extends Node2D
class_name EquipmentItem

signal on_pickup(item: Item)

@onready var sprite = $Sprite2D
@onready var interaction_area = $InteractionArea
@onready var name_label = $NameLabel
@onready var hover_animation = $HoverAnimation

var item: Item
var item_texture: CompressedTexture2D

func _ready() -> void:
	interaction_area.mouse_entered.connect(_on_mouse_entered)
	interaction_area.mouse_exited.connect(_on_mouse_exited)
	interaction_area.input_event.connect(_on_input_event)
	
	if item:
		setup_item_visuals()

func setup_item_visuals() -> void:
	# Set texture based on item type
	var texture_path = "res://entities/items/assets/%s.png" % item.base_item.item_type.to_lower()
	item_texture = load(texture_path)
	if item_texture:
		sprite.texture = item_texture
	
	# Set name label
	name_label.text = item.get_display_name()
	
	# Set color based on rarity
	match item.rarity:
		ItemGenerator.Rarity.COMMON:
			name_label.modulate = Color.WHITE
		ItemGenerator.Rarity.MAGIC:
			name_label.modulate = Color.BLUE
		ItemGenerator.Rarity.RARE:
			name_label.modulate = Color.YELLOW

func _on_mouse_entered() -> void:
	hover_animation.play("hover")
	name_label.show()

func _on_mouse_exited() -> void:
	hover_animation.play_backwards("hover")
	name_label.hide()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("interact"):
		emit_signal("on_pickup", item)
		queue_free() 
