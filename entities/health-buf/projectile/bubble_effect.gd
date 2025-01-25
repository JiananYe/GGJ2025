extends Node2D

@export var potion_sprite : Sprite2D
@export var number_of_sprites : int = 4

# Start positions and offsets around the potion_sprite
var offsets = [Vector2(-30, -30), Vector2(30, -30), Vector2(-30, 30), Vector2(30, 30)]
var speed = 1.0  # Speed of the movement

func _ready():
	# Duplicate and position the sprites
	for i in range(number_of_sprites):
		var new_sprite = potion_sprite.instantiate()
		add_child(new_sprite)
		new_sprite.position = potion_sprite.position + offsets[i]
		new_sprite.scale = Vector2(randf_range(0.5, 1.5), randf_range(0.5, 1.5))
		
		# Animate the sprite movement
		animate_sprite(new_sprite)

# Function to animate the sprite with a sinusoidal trajectory
func animate_sprite(sprite: Sprite2D):
	var animation_duration = 1.0  # Duration of the movement
	var tween = create_tween()
	var start_position = sprite.position
	var end_position = start_position + Vector2(0, -100)  # Move up 100 pixels
