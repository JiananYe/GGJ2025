extends Area2D

var speed: float = 400.0
var damage: float = 15.0
var direction: Vector2 = Vector2.RIGHT
var caster: Node2D

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func init(initial_position: Vector2, angle: float, projectile_damage: float, projectile_speed: float, projectile_caster: Node2D, duration: float = 2.0) -> void:
	position = initial_position
	direction = Vector2.RIGHT.rotated(angle)
	damage = projectile_damage
	speed = projectile_speed
	caster = projectile_caster
	rotation = angle
	
	# Set lifetime
	var timer = get_tree().create_timer(duration)
	timer.timeout.connect(queue_free)

func _on_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	if body == caster:
		return
		
	if body.has_method("take_hit") and body.is_in_group("player"):
		body.take_hit(damage)
		queue_free() 