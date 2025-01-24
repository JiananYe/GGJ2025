extends EntityStateMachine

func _ready() -> void:
	add_to_group("player")
	# ... rest of your ready function

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
