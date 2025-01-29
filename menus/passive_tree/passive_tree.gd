extends Control
class_name PassiveTree

signal point_allocated(node_id: String)
signal point_deallocated(node_id: String)
signal closed

var available_points: int = 0
var allocated_nodes: Dictionary = {}  # node_id: PassiveNode
var starting_node: PassiveNode
var passive_node_scene = preload("res://menus/passive_tree/passive_node.tscn")

# Add these variables for positioning
var center_offset: Vector2
const BASE_RADIUS = 300  # Distance from center to cluster centers
const CLUSTER_RADIUS = 120  # Radius of each circular cluster
const NODES_PER_CLUSTER = 6  # Number of nodes in outer circle of cluster
const INNER_CLUSTER_RADIUS = 60  # Radius for inner circle nodes

# Add these variables for dragging
var dragging: bool = false
var drag_start_position: Vector2
var initial_container_position: Vector2

# Add at the top with other variables
var pending_stat_application := false
var total_points_earned: int = 0  # Track total points from ascension
var ascension_level: int = 0
var ascension_exp: float = 0.0
var exp_to_next_ascension: float = 100.0  # Base exp needed
const ASCENSION_EXP_MULTIPLIER = 1.5  # Each level requires 50% more exp

@onready var node_container: Node2D = $NodeContainer
@onready var line_container: Node2D = $LineContainer
@onready var points_label: Label = $PointsLabel
@onready var exp_bar: ProgressBar = $ExpBar

func _ready() -> void:
	add_to_group("passive_tree")
	
	# Calculate center of the screen
	center_offset = get_viewport_rect().size / 2
	# Move node container to center
	node_container.position = center_offset
	line_container.position = center_offset
	
	setup_tree()
	update_points_display()
	update_exp_bar()
	
	# Connect save button
	$SaveButton.pressed.connect(_on_save_button_pressed)
	
	# Check for player every frame when we have pending stats
	if pending_stat_application:
		process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	if pending_stat_application:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			apply_all_stats_to_player(player)
			pending_stat_application = false
			process_mode = Node.PROCESS_MODE_INHERIT

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Start dragging
				dragging = true
				drag_start_position = event.position
				initial_container_position = node_container.position
			else:
				# Stop dragging
				dragging = false
	
	elif event is InputEventMouseMotion and dragging:
		# Calculate drag offset and move containers
		var drag_offset = event.position - drag_start_position
		node_container.position = initial_container_position + drag_offset
		line_container.position = node_container.position

func setup_tree() -> void:
	# Create starting node (center)
	starting_node = create_passive_node("start", Vector2.ZERO, {
		"max_hp": 10.0,
		"max_mana": 10.0
	}, PassiveNode.IconType.CENTER)
	starting_node.allocate()  # Starting node is always allocated
	allocated_nodes[starting_node.node_id] = starting_node
	
	# Create attribute clusters
	create_defensive_cluster()
	create_offensive_cluster()
	create_projectile_cluster()
	create_utility_cluster()

func create_defensive_cluster() -> void:
	var cluster_center = Vector2(0, -BASE_RADIUS)
	var nodes = []
	
	# Create center node of cluster
	var center_node = create_passive_node("def_center", cluster_center, {
		"armor": 8.0,
		"evasion": 8.0
	}, PassiveNode.IconType.DEFENSIVE)
	
	# Create outer circle of nodes
	for i in range(NODES_PER_CLUSTER):
		var angle = (2 * PI * i) / NODES_PER_CLUSTER
		var offset = Vector2(
			cos(angle) * CLUSTER_RADIUS,
			sin(angle) * CLUSTER_RADIUS
		)
		
		var node_stats = {}
		match i:
			0, 1:
				node_stats["armor"] = 5.0
			2, 3:
				node_stats["evasion"] = 5.0
			4, 5:
				node_stats["resistance"] = 5.0
		
		var node = create_passive_node("def_outer_%d" % i, cluster_center + offset, node_stats, PassiveNode.IconType.DEFENSIVE)
		nodes.append(node)
	
	# Create inner circle nodes
	for i in range(3):
		var angle = (2 * PI * i) / 3 + PI/6  # Offset by 30 degrees
		var offset = Vector2(
			cos(angle) * INNER_CLUSTER_RADIUS,
			sin(angle) * INNER_CLUSTER_RADIUS
		)
		
		var node_stats = {}
		match i:
			0:
				node_stats["armor"] = 10.0
			1:
				node_stats["evasion"] = 10.0
			2:
				node_stats["resistance"] = 10.0
		
		var node = create_passive_node("def_inner_%d" % i, cluster_center + offset, node_stats, PassiveNode.IconType.DEFENSIVE)
		nodes.append(node)
	
	# Connect nodes
	connect_cluster(center_node, nodes)
	connect_to_start(center_node)

func create_offensive_cluster() -> void:
	var cluster_center = Vector2(BASE_RADIUS, 0)
	var nodes = []
	
	# Create center node of cluster
	var center_node = create_passive_node("off_center", cluster_center, {
		"damage_multiplier": 15.0,
		"crit_chance": 3.0
	}, PassiveNode.IconType.OFFENSIVE)
	
	# Create outer circle of nodes
	for i in range(NODES_PER_CLUSTER):
		var angle = (2 * PI * i) / NODES_PER_CLUSTER
		var offset = Vector2(
			cos(angle) * CLUSTER_RADIUS,
			sin(angle) * CLUSTER_RADIUS
		)
		
		var node_stats = {}
		match i:
			0, 1:
				node_stats["damage_multiplier"] = 10.0
			2, 3:
				node_stats["crit_chance"] = 5.0
			4, 5:
				node_stats["crit_multiplier"] = 0.2
		
		var node = create_passive_node("off_outer_%d" % i, cluster_center + offset, node_stats, PassiveNode.IconType.OFFENSIVE)
		nodes.append(node)
	
	# Create inner circle nodes
	for i in range(3):
		var angle = (2 * PI * i) / 3 + PI/6
		var offset = Vector2(
			cos(angle) * INNER_CLUSTER_RADIUS,
			sin(angle) * INNER_CLUSTER_RADIUS
		)
		
		var node_stats = {}
		match i:
			0:
				node_stats["damage_multiplier"] = 20.0
			1:
				node_stats["crit_chance"] = 10.0
			2:
				node_stats["crit_multiplier"] = 0.3
		
		var node = create_passive_node("off_inner_%d" % i, cluster_center + offset, node_stats, PassiveNode.IconType.OFFENSIVE)
		nodes.append(node)
	
	connect_cluster(center_node, nodes)
	connect_to_start(center_node)

func create_projectile_cluster() -> void:
	var cluster_center = Vector2(0, BASE_RADIUS)
	var nodes = []
	
	var center_node = create_passive_node("proj_center", cluster_center, {
		"projectile_damage": 15.0,
		"projectile_speed": 15.0
	}, PassiveNode.IconType.PROJECTILE)
	
	# Outer circle
	for i in range(NODES_PER_CLUSTER):
		var angle = (2 * PI * i) / NODES_PER_CLUSTER
		var offset = Vector2(cos(angle) * CLUSTER_RADIUS, sin(angle) * CLUSTER_RADIUS)
		
		var node_stats = {}
		match i:
			0, 1:
				node_stats["projectile_damage"] = 10.0
			2, 3:
				node_stats["projectile_speed"] = 10.0
			4, 5:
				node_stats["projectile_duration"] = 0.2
		
		var node = create_passive_node("proj_outer_%d" % i, cluster_center + offset, node_stats, PassiveNode.IconType.PROJECTILE)
		nodes.append(node)
	
	# Inner circle
	for i in range(3):
		var angle = (2 * PI * i) / 3 + PI/6
		var offset = Vector2(cos(angle) * INNER_CLUSTER_RADIUS, sin(angle) * INNER_CLUSTER_RADIUS)
		
		var node_stats = {}
		match i:
			0:
				node_stats["projectile_damage"] = 20.0
			1:
				node_stats["projectile_speed"] = 20.0
			2:
				node_stats["projectile_duration"] = 0.4
		
		var node = create_passive_node("proj_inner_%d" % i, cluster_center + offset, node_stats, PassiveNode.IconType.PROJECTILE)
		nodes.append(node)
	
	connect_cluster(center_node, nodes)
	connect_to_start(center_node)

func create_utility_cluster() -> void:
	var cluster_center = Vector2(-BASE_RADIUS, 0)
	var nodes = []
	
	# Create center node of cluster
	var center_node = create_passive_node("util_center", cluster_center, {
		"mana_regeneration_rate": 8.0,
		"cast_speed": 15.0  # 15% increased cast speed
	}, PassiveNode.IconType.UTILITY)
	
	# Create outer circle of nodes
	for i in range(NODES_PER_CLUSTER):
		var angle = (2 * PI * i) / NODES_PER_CLUSTER
		var offset = Vector2(
			cos(angle) * CLUSTER_RADIUS,
			sin(angle) * CLUSTER_RADIUS
		)
		
		var node_stats = {}
		match i:
			0, 1:
				node_stats["mana_regeneration_rate"] = 5.0
			2, 3:
				node_stats["cast_speed"] = 8.0  # 8% increased cast speed
			4, 5:
				node_stats["max_mana"] = 25.0
		
		var node = create_passive_node("util_outer_%d" % i, cluster_center + offset, node_stats, PassiveNode.IconType.UTILITY)
		nodes.append(node)
	
	# Create inner circle nodes
	for i in range(3):
		var angle = (2 * PI * i) / 3 + PI/6
		var offset = Vector2(
			cos(angle) * INNER_CLUSTER_RADIUS,
			sin(angle) * INNER_CLUSTER_RADIUS
		)
		
		var node_stats = {}
		match i:
			0:
				node_stats["mana_regeneration_rate"] = 10.0
			1:
				node_stats["cast_speed"] = 20.0  # 20% increased cast speed
			2:
				node_stats["max_mana"] = 50.0
		
		var node = create_passive_node("util_inner_%d" % i, cluster_center + offset, node_stats, PassiveNode.IconType.UTILITY)
		nodes.append(node)
	
	# Connect nodes
	connect_cluster(center_node, nodes)
	connect_to_start(center_node)

func create_passive_node(id: String, pos: Vector2, stats: Dictionary, icon_type: int = PassiveNode.IconType.DEFAULT) -> PassiveNode:
	var node = passive_node_scene.instantiate() as PassiveNode
	if not node:
		push_error("Failed to instantiate PassiveNode scene")
		return null
		
	node.setup(id, pos, stats, icon_type)
	node.clicked.connect(_on_node_clicked)
	node_container.add_child(node)
	return node

# Helper function to connect nodes in a chain
func connect_chain(nodes: Array) -> void:
	for i in range(nodes.size() - 1):
		connect_nodes_directly(nodes[i], nodes[i + 1])

# Helper function to connect first node in chain to starting node
func connect_chain_to_start(first_node: PassiveNode) -> void:
	connect_nodes_directly(starting_node, first_node)

# Connect two nodes directly with a line
func connect_nodes_directly(node1: PassiveNode, node2: PassiveNode) -> void:
	node1.add_neighbor(node2)
	create_connection_line(node1, node2)

func create_connection_line(node1: PassiveNode, node2: PassiveNode) -> void:
	var line = Line2D.new()
	line.default_color = Color(0.5, 0.5, 0.5, 0.5)
	line.width = 2
	line.add_point(node1.position)
	line.add_point(node2.position)
	line_container.add_child(line)

func _on_node_clicked(node: PassiveNode) -> void:
	if can_allocate_node(node):
		allocate_node(node)
	elif can_deallocate_node(node):
		deallocate_node(node)

func can_allocate_node(node: PassiveNode) -> bool:
	if node.is_allocated or available_points <= 0:
		return false
	
	# Check if connected to an allocated node
	for neighbor in node.neighbors:
		if neighbor.is_allocated:
			return true
	
	return false

func can_deallocate_node(node: PassiveNode) -> bool:
	if not node.is_allocated or node == starting_node:
		return false
	
	# Check if removing this node would disconnect the tree
	var would_disconnect = false
	node.is_allocated = false
	# TODO: Implement graph traversal to check connectivity
	node.is_allocated = true
	
	return not would_disconnect

func allocate_node(node: PassiveNode) -> void:
	node.allocate()
	allocated_nodes[node.node_id] = node
	available_points -= 1
	update_points_display()
	emit_signal("point_allocated", node.node_id)
	apply_node_stats_to_player(node, true)

func deallocate_node(node: PassiveNode) -> void:
	node.deallocate()
	allocated_nodes.erase(node.node_id)
	available_points += 1
	update_points_display()
	emit_signal("point_deallocated", node.node_id)
	apply_node_stats_to_player(node, false)

func update_points_display() -> void:
	points_label.text = "Available Points: %d\nAscension Level: %d" % [
		available_points,
		ascension_level
	]

func update_exp_bar() -> void:
	exp_bar.max_value = get_exp_to_next_ascension()
	exp_bar.value = ascension_exp

func get_exp_to_next_ascension() -> float:
	return exp_to_next_ascension * pow(ASCENSION_EXP_MULTIPLIER, ascension_level)

func apply_node_stats_to_player(node: PassiveNode, is_adding: bool) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		pending_stat_application = true
		return
		
	for stat_name in node.stats:
		var value = node.stats[stat_name]
		if !is_adding:
			value = -value  # Negate value when removing stats
			
		match stat_name:
			"max_hp":
				player.max_hp += value
				player.current_hp = min(player.current_hp + value, player.max_hp)
			"max_mana":
				player.max_mana += value
				player.current_mana = min(player.current_mana + value, player.max_mana)
			"armor":
				player.armor += value
			"evasion":
				player.evasion += value
			"resistance":
				player.resistance += value
			"damage_multiplier":
				player.damage_multiplier += value / 100.0
			"projectile_damage":
				player.projectile_damage += value
			"crit_chance":
				player.crit_chance += value
			"crit_multiplier":
				player.crit_multiplier += value
			"mana_regeneration_rate":
				player.mana_regeneration_rate += value
			"cast_speed":
				player.modify_cast_speed(value / 100.0)  # Convert percentage to multiplier

# Helper functions for connecting nodes
func connect_cluster(center_node: PassiveNode, nodes: Array) -> void:
	# Connect center to inner circle
	for i in range(3):
		connect_nodes_directly(center_node, nodes[NODES_PER_CLUSTER + i])
	
	# Connect inner circle to outer circle
	for i in range(3):
		var inner_node = nodes[NODES_PER_CLUSTER + i]
		# Connect to two closest outer nodes
		var outer_indices = [i * 2, i * 2 + 1]
		for idx in outer_indices:
			connect_nodes_directly(inner_node, nodes[idx])

func connect_to_start(node: PassiveNode) -> void:
	connect_nodes_directly(starting_node, node)

func apply_all_stats_to_player(player: Node) -> void:
	# Reset player stats to base values first
	player.reset_to_base_stats()
	
	# Apply all allocated node stats
	for node in allocated_nodes.values():
		for stat_name in node.stats:
			var value = node.stats[stat_name]
			match stat_name:
				"max_hp":
					player.max_hp += value
					player.current_hp = min(player.current_hp + value, player.max_hp)
				"max_mana":
					player.max_mana += value
					player.current_mana = min(player.current_mana + value, player.max_mana)
				"armor":
					player.armor += value
				"evasion":
					player.evasion += value
				"resistance":
					player.resistance += value
				"damage_multiplier":
					player.damage_multiplier += value / 100.0
				"projectile_damage":
					player.projectile_damage += value
				"crit_chance":
					player.crit_chance += value
				"crit_multiplier":
					player.crit_multiplier += value
				"mana_regeneration_rate":
					player.mana_regeneration_rate += value
				"cast_speed":
					player.modify_cast_speed(value / 100.0)  # Convert percentage to multiplier

func _on_save_button_pressed() -> void:
	# Save changes if needed
	# TODO: Implement save functionality
	
	# Set pending application flag
	pending_stat_application = true
	
	# Hide the passive tree and show main menu
	hide()
	emit_signal("closed")

# Add this function to receive exp from player level ups
func add_ascension_exp(amount: float) -> void:
	ascension_exp += amount
	
	# Check for level ups
	while ascension_exp >= get_exp_to_next_ascension():
		ascend()
	
	update_exp_bar()

func ascend() -> void:
	ascension_exp -= get_exp_to_next_ascension()
	ascension_level += 1
	available_points += 1
	total_points_earned += 1
	update_points_display()
	update_exp_bar()
