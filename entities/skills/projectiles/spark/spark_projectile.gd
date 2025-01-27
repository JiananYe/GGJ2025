extends Area2D
class_name SparkProjectile

var speed: float = 1000.0
var damage: float = 0.0
var direction: Vector2 = Vector2.RIGHT
var bounces_remaining: int = 3
var bounce_angle_variation: float = PI/4  # 45 degrees variation
var caster: Node2D  # Store reference to caster
var time_offset: float = randf() * PI * 2  # Random starting point for sinusoidal movement
var sinusoidal_amplitude: float = 3.0  # Control the deviation from the original line
var initial_speed: float = 0.0  # Store the initial speed for exponential decay
var is_bursting: bool = false

func _ready() -> void:
	# Connect to the animation finished signal
	$Sprite2D.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	if is_bursting:
		return
	var time = Time.get_ticks_msec() / 1000.0
	var sinusoidal_offset = Vector2(-direction.y, direction.x) * sin(time * 5 + time_offset) * sinusoidal_amplitude
	if $LifetimeTimer.time_left < 0.3:  # Start slowing down exponentially in the last 0.2 seconds
		speed = initial_speed * exp(-5 * (0.2 - $LifetimeTimer.time_left))
	position += direction * speed * delta + sinusoidal_offset

func init(initial_position: Vector2, angle: float, projectile_damage: float, projectile_speed: float, projectile_caster: Node2D, duration: float = 3.0) -> void:
	position = initial_position
	direction = Vector2.RIGHT.rotated(angle)
	damage = projectile_damage
	speed = projectile_speed * (0.9 + randf() * 0.4)  # Add random variation to speed
	var speed_variation = sin(time_offset) * projectile_speed * 0.4  # Amplitude of 0.5 times the projectile speed
	speed = projectile_speed + speed_variation
	initial_speed = speed  # Store the initial speed
	caster = projectile_caster
	# Set initial rotation
	rotation = angle
	time_offset = randf() * PI * 2  # Initialize time offset for each projectile
	
	# Set lifetime timer duration
	if has_node("LifetimeTimer"):
		$LifetimeTimer.wait_time = duration
		$LifetimeTimer.start()

func _on_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	# Ignore collision with caster
	if body == caster:
		return
		
	if body.has_method("take_hit"):
		body.take_hit(damage, "physical")
	start_burst_animation()
	#elif bounces_remaining > 0:
		#bounce(body)

func start_burst_animation() -> void:
	is_bursting = true
	$CollisionShape2D.set_deferred("disabled", true)  # Disable collision
	$Sprite2D.play("burst")

func _on_animation_finished() -> void:
	if is_bursting:
		queue_free()

func bounce(collision_body: Node2D) -> void:
	bounces_remaining -= 1
	
	# Add random variation to bounce angle
	var random_variation = randf_range(-bounce_angle_variation, bounce_angle_variation)
	direction = direction.bounce(Vector2.RIGHT).rotated(random_variation)
	# Update rotation after bounce
	rotation = direction.angle()
	
	if collision_body is HealthBuffSpawner:
		return
	
	# Prevent colliding with the same body immediately
	set_collision_mask_value(collision_body.collision_layer, false)
	await get_tree().create_timer(0.1).timeout
	set_collision_mask_value(collision_body.collision_layer, true)

func _on_lifetime_timer_timeout() -> void:
	start_burst_animation()
