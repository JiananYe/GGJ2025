extends Area2D
class_name SparkProjectile

var speed: float = 1000.0
var damage: float = 0.0
var direction: Vector2 = Vector2.RIGHT
var bounces_remaining: int = 3
var bounce_angle_variation: float = PI/4  # 45 degrees variation
var caster: Node2D  # Store reference to caster

func _ready() -> void:
	$AnimatedSprite2D.play("default")
	# Set initial rotation based on direction
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	# Update rotation to match movement direction
	rotation = direction.angle()

func init(initial_position: Vector2, angle: float, projectile_damage: float, projectile_speed: float, projectile_caster: Node2D, duration: float = 3.0) -> void:
	position = initial_position
	direction = Vector2.RIGHT.rotated(angle)
	damage = projectile_damage
	speed = projectile_speed
	caster = projectile_caster
	# Set initial rotation
	rotation = angle
	
	# Set lifetime timer duration
	if has_node("LifetimeTimer"):
		$LifetimeTimer.wait_time = duration
		$LifetimeTimer.start()

func _on_body_entered(body: Node2D) -> void:
	# Ignore collision with caster
	if body == caster:
		return
		
	if body.has_method("take_hit"):
		body.take_hit(damage, "lightning")
		queue_free()
	elif bounces_remaining > 0:
		bounce(body)
	else:
		queue_free()

func bounce(collision_body: Node2D) -> void:
	bounces_remaining -= 1
	
	# Add random variation to bounce angle
	var random_variation = randf_range(-bounce_angle_variation, bounce_angle_variation)
	direction = direction.bounce(Vector2.RIGHT).rotated(random_variation)
	# Update rotation after bounce
	rotation = direction.angle()
	
	# Prevent colliding with the same body immediately
	set_collision_mask_value(collision_body.collision_layer, false)
	await get_tree().create_timer(0.1).timeout
	set_collision_mask_value(collision_body.collision_layer, true)

func _on_lifetime_timer_timeout() -> void:
	queue_free() 
