extends CharacterBody2D

enum PlayerState {
	IDLE,
	WALKING,
	ATTACKING,
	HURT,
	DYING
}

const SPEED = 300.0

var current_state: PlayerState = PlayerState.IDLE
var is_dead: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	# Start in idle state
	change_state(PlayerState.IDLE)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
	# Handle movement with WASD
	var direction = Vector2.ZERO
	direction.x = Input.get_axis("left", "right")
	direction.y = Input.get_axis("up", "down")
	
	# Normalize diagonal movement
	if direction.length() > 1.0:
		direction = direction.normalized()
	
	velocity = direction * SPEED
	
	# Update sprite direction
	if direction.x != 0:
		animated_sprite.flip_h = direction.x < 0
	
	# State machine logic
	match current_state:
		PlayerState.IDLE:
			handle_idle_state()
		PlayerState.WALKING:
			handle_walking_state()
		PlayerState.ATTACKING:
			handle_attacking_state()
		PlayerState.HURT:
			handle_hurt_state()
		PlayerState.DYING:
			handle_dying_state()
	
	move_and_slide()

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
