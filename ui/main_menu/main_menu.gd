class_name MainMenu
extends Control


signal death_menu_fade_finished
signal start_game_signal


@onready var death_menu: Control = $DeathMenu
@onready var black_background: Panel = $DeathMenu/BlackBackground
@onready var you_died: MarginContainer = $DeathMenu/YouDied
@onready var bubble_shader: ColorRect = $MainMenu/CanvasLayer/TextureRect


var is_main_menu_displaying := true
var is_bubble_walking_in := false
var shader_bubble_init_center := Vector2(0.5, 0.5)
var shader_bubble_walk_in_speed := 0.3
var shader_bubble_walk_in_position := Vector2(0.5, 1.5)
var shader_bubble_center := Vector2(0.5, 0.5)
var shader_bubble_amplitude := Vector2(0.05, 0.06)


func _ready() -> void:
	DirtyDirtyUiManager.main_menu = self
	for node in get_tree().get_nodes_in_group("game_overlay"):
		node.hide()
	hide_death_menu()
	shader_bubble_center = shader_bubble_walk_in_position
	move_shader_bubble_center(shader_bubble_walk_in_position)
	is_bubble_walking_in = true


func _process(delta: float) -> void:
	if is_bubble_walking_in:
		var distance = shader_bubble_center.y - shader_bubble_init_center.y
		var easing_factor = (distance * 7) if distance < 0.1 else 1.0  # Ease only at the very end
		shader_bubble_center.y -= shader_bubble_walk_in_speed * delta * easing_factor
		move_shader_bubble_center(shader_bubble_center)
		if shader_bubble_center.y <= shader_bubble_init_center.y:
			is_bubble_walking_in = false
	#
	if is_main_menu_displaying:
		var time = Time.get_ticks_msec() / 1000.0
		float_shader_bubble(time)



func trigger_death_menu():
	#you_died.modulate.a = 0
	#black_background.modulate.a = 0
	#you_died.show()
	#black_background.show()
	#await fade_in(you_died, 2.5)
	#await fade_in(black_background, 2)
	#await get_tree().create_timer(3).timeout
	death_menu_fade_finished.emit()


func fade_in(node: CanvasItem, duration: float) -> void:
	var time_passed := 0.0
	while time_passed < duration:
		time_passed += get_process_delta_time()
		node.modulate.a = time_passed / duration
		await get_tree().process_frame


func hide_death_menu():
	black_background.modulate.a = 0
	you_died.modulate.a = 0


func start_game():
	for node in get_tree().get_nodes_in_group("game_overlay"):
		node.show()


func move_shader_bubble_center(pos: Vector2) -> void:
	var shader = bubble_shader.material
	(shader as ShaderMaterial).set_shader_parameter("effect_center", pos)


func float_shader_bubble(time: float) -> void:
	var center_x = shader_bubble_center.x + sin(time) * shader_bubble_amplitude.x
	var center_y = shader_bubble_center.y + cos(time * 0.5) * shader_bubble_amplitude.y
	move_shader_bubble_center(Vector2(center_x, center_y))
