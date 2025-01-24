extends EntityStateMachine

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func die() -> void:
	if current_state != PlayerState.DYING:
		change_state(PlayerState.DYING)
		is_dead = true
		# Disable collision
		collision_shape.set_deferred("disabled", true)
		# Make player semi-transparent
		modulate.a = 0.5
		# Disable processing
		set_physics_process(false)
		# Optional: emit signal for game over handling
		# emit_signal("player_died")
