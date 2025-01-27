class_name EntityStateMachine

extends Entity

enum PlayerState {
	IDLE,
	WALKING,
	ATTACKING,
	HURT,
	DYING
}

var speed = 400.0

var current_state: PlayerState = PlayerState.IDLE
var is_dead: bool = false

var equipment_item_scene = preload("res://entities/items/EquipmentItem.tscn")
var item_generator: ItemGenerator

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	# Start in idle state
	change_state(PlayerState.IDLE)

func handle_idle_state() -> void:
	if Input.is_action_just_pressed("attack"):
		change_state(PlayerState.ATTACKING)
	elif velocity.length() > 0:
		change_state(PlayerState.WALKING)
		return

func handle_walking_state() -> void:
	if Input.is_action_just_pressed("attack"):
		change_state(PlayerState.ATTACKING)
	elif velocity.length() == 0:
		change_state(PlayerState.IDLE)

func handle_attacking_state() -> void:
	if !animated_sprite.is_playing():
		change_state(PlayerState.IDLE)

func handle_hurt_state() -> void:
	if !animated_sprite.is_playing():
		change_state(PlayerState.IDLE)

func handle_dying_state() -> void:
	if !animated_sprite.is_playing():
		is_dead = true
		# You might want to emit a signal or handle death here

func change_state(new_state: PlayerState) -> void:
	current_state = new_state
	
	# Update animation based on state
	match current_state:
		PlayerState.IDLE:
			animated_sprite.play("idle")
		PlayerState.WALKING:
			animated_sprite.play("walking")
		PlayerState.ATTACKING:
			animated_sprite.play("attacking")
		PlayerState.HURT:
			animated_sprite.play("hurt")
		PlayerState.DYING:
			animated_sprite.play("dying")

func take_damage() -> void:
	if current_state != PlayerState.HURT and current_state != PlayerState.DYING:
		change_state(PlayerState.HURT)

func die() -> void:
	if current_state != PlayerState.DYING:
		change_state(PlayerState.DYING)


func drop_random_item() -> void:
	var base_item = BaseItemsDB.get_random_base_item()
	var dropped_item = item_generator.generate_item(base_item, level)
	
	var item_node = equipment_item_scene.instantiate()
	item_node.item = dropped_item
	get_parent().call_deferred("add_child", item_node)
	item_node.global_position = global_position
	
	# Drop animation
	item_node.scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(item_node, "scale", Vector2.ONE, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
