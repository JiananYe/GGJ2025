extends Node2D
class_name PassiveNode

signal clicked(node: PassiveNode)

var node_id: String
var stats: Dictionary
var is_allocated: bool = false
var neighbors: Array[PassiveNode] = []
var pending_tooltip: String = ""
var pending_position: Vector2 = Vector2.ZERO
var click_start_position: Vector2

# Add icon type enum
enum IconType {
	DEFAULT,
	DEFENSIVE,
	OFFENSIVE,
	PROJECTILE,
	UTILITY,
	CENTER
}

var icon_type: IconType = IconType.DEFAULT
var setup_data: Dictionary

# Export icon paths
@export var defensive_icon: Texture2D
@export var offensive_icon: Texture2D
@export var projectile_icon: Texture2D
@export var utility_icon: Texture2D
@export var center_icon: Texture2D

const LINE_HEIGHT = 20  # Height per line of text
const PADDING = 10  # Padding around the text
const MIN_WIDTH = 200  # Minimum width for tooltip

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $TooltipContainer/Label
@onready var icon_sprite: Sprite2D = $IconSprite
@onready var tooltip_container: Control = $TooltipContainer
@onready var tooltip_background: Panel = $TooltipContainer/Background

func _ready() -> void:
	if setup_data:
		node_id = setup_data.id
		position = setup_data.pos
		stats = setup_data.stats
		icon_type = setup_data.type
		
		# Create and set tooltip text
		var tooltip_text = create_tooltip_text()
		label.text = tooltip_text
		
		# Wait one frame for the label to update its size
		await get_tree().process_frame
		
		# Get the actual size needed for the text
		var label_size = label.get_minimum_size()
		var width = max(MIN_WIDTH, label_size.x + PADDING * 2)
		var height = label_size.y + PADDING * 2
		
		# Update container and background size
		tooltip_container.custom_minimum_size = Vector2(width, height)
		tooltip_container.size = Vector2(width, height)
		tooltip_container.position = Vector2(-width/2, -height - 30)  # Center above node
		tooltip_container.visible = false
		
		# Update visuals
		update_appearance()
		update_icon()

func create_default_texture() -> Texture2D:
	var image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	return ImageTexture.create_from_image(image)

func setup(id: String, pos: Vector2, node_stats: Dictionary, type: IconType = IconType.DEFAULT) -> void:
	# Store setup data for _ready
	setup_data = {
		"id": id,
		"pos": pos,
		"stats": node_stats,
		"type": type
	}
	
	# If we're already in the tree, apply setup immediately
	if is_inside_tree():
		_ready()

func add_neighbor(node: PassiveNode) -> void:
	if not neighbors.has(node):
		neighbors.append(node)
		node.neighbors.append(self)

func allocate() -> void:
	is_allocated = true
	update_appearance()

func deallocate() -> void:
	is_allocated = false
	update_appearance()

func update_appearance() -> void:
	if not sprite:
		return
		
	if is_allocated:
		sprite.modulate = Color(0.2, 0.8, 0.2)  # Green for allocated
	else:
		sprite.modulate = Color(0.5, 0.5, 0.5)  # Gray for unallocated

func create_tooltip_text() -> String:
	var text = ""
	for stat_name in stats:
		var value = stats[stat_name]
		text += "%s: +%s\n" % [stat_name.capitalize(), value]
	return text.strip_edges()  # Remove trailing newline

func update_icon() -> void:
	if not icon_sprite:
		return
		
	match icon_type:
		IconType.DEFENSIVE:
			icon_sprite.texture = defensive_icon
		IconType.OFFENSIVE:
			icon_sprite.texture = offensive_icon
		IconType.PROJECTILE:
			icon_sprite.texture = projectile_icon
		IconType.UTILITY:
			icon_sprite.texture = utility_icon
		IconType.CENTER:
			icon_sprite.texture = center_icon
		_:  # DEFAULT
			icon_sprite.texture = null

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			click_start_position = event.global_position
		elif click_start_position.distance_to(event.global_position) < 5:
			# Only emit click if mouse hasn't moved much (not dragging)
			emit_signal("clicked", self) 

func _on_area_2d_mouse_entered() -> void:
	tooltip_container.visible = true

func _on_area_2d_mouse_exited() -> void:
	tooltip_container.visible = false 
