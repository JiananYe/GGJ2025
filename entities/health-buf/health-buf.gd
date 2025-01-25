extends Area2D

@export var health_amount: int = 50  # Amount of health restored when picked up
@onready var sprite: Sprite2D = $Potion
@onready var collision: CollisionShape2D = $CollisionShape2D

var player: Node2D
var collision_active: bool = true  # Track whether collision is currently enabled

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	if not player:
		push_error("Player node not found!")

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
	_play_pickup_animation()

func _apply_health_buff(player: Node2D) -> void:
	if player.has_method("increase_health"):
		player.increase_health(health_amount)

func _play_pickup_animation() -> void:
	sprite.visible = false
	collision.set_deferred("disabled", true)

func _on_animated_sprite_animation_finished():
	queue_free()  # Remove the health buffer from the scene
