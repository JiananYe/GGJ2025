extends Node2D
class_name EquipmentItem

signal on_pickup(item: Item)

@onready var sprite = $Sprite2D
@onready var interaction_area = $InteractionArea
@onready var name_label = $NameLabel
@onready var hover_animation = $HoverAnimation

var item: Item
var item_texture: CompressedTexture2D
const TARGET_SIZE = 96.0  # Target size in pixels
var base_scale: Vector2  # Store the initial scale

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
		# Scale sprite to target size while maintaining aspect ratio
		var max_dimension = max(item_texture.get_width(), item_texture.get_height())
		var scale_factor = TARGET_SIZE / max_dimension
		base_scale = Vector2(scale_factor, scale_factor)
		sprite.scale = base_scale
		
		# Update animation with correct base scale
		var anim = hover_animation.get_animation("hover")
		anim.track_set_key_value(0, 0, base_scale)  # Initial scale
		anim.track_set_key_value(0, 1, base_scale * 1.2)  # Hover scale
		
		var reset_anim = hover_animation.get_animation("RESET")
		reset_anim.track_set_key_value(0, 0, base_scale)
	
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
		# Find the player and check if the slot is empty
		var player = get_tree().get_first_node_in_group("player")
		if player and player.is_equipment_slot_empty(item.base_item.item_type.to_lower()):
			var game_overlay = get_tree().get_first_node_in_group("game_overlay")
			game_overlay._on_item_pickup(item)
			queue_free()
		else:
			# Optional: Show feedback that slot is occupied
			print("Cannot pick up item - slot is occupied")
