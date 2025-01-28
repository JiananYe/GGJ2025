extends Area2D

@export var health_amount: int = 50  # Amount of health restored when picked up
@onready var sprite: Sprite2D = $Potion
@onready var collision: CollisionShape2D = $CollisionShape2D

var health_buf_number = preload("res://entities/ui/HealthBufNumber.tscn")
var player: Node2D
var collision_active: bool = true  # Track whether collision is currently enabled

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	if not player:
		push_error("Player node not found!")
	
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if collision_active:
		_check_for_collision()

func _on_body_entered(body: Node) -> void:
	if collision_active and body == player:
		_handle_collision()

func _check_for_collision() -> void:
	# Explicitly check overlapping bodies to ensure collision
	for body in get_overlapping_bodies():
		if body == player:
			_handle_collision()

func _handle_collision() -> void:
	collision_active = false
	_apply_health_buff(player)
	_spawn_health_number()
	queue_free()

func _apply_health_buff(player: Node2D) -> void:
	if player.has_method("heal"):
		player.heal(health_amount)

func _spawn_health_number() -> void:
	var number = health_buf_number.instantiate()
	get_tree().current_scene.add_child(number)
	number.global_position = global_position
	number.setup(health_amount)

func _on_animated_sprite_animation_finished():
	queue_free()  # Remove the health buffer from the scene
