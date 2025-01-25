extends Area2D
class_name SparkProjectile

var speed: float = 1000.0
var damage: float = 0.0
var direction: Vector2 = Vector2.RIGHT
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
	else:
		queue_free()

func _on_lifetime_timer_timeout() -> void:
	queue_free() 
