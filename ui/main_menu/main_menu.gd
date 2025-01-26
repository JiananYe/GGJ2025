class_name MainMenu
extends Control


signal death_menu_fade_finished
signal start_game_signal


@onready var death_menu: Control = $DeathMenu
@onready var black_background: Panel = $DeathMenu/BlackBackground
@onready var you_died: MarginContainer = $DeathMenu/YouDied
@onready var bubble_shader: ColorRect = $MainMenu/CanvasLayer/TextureRect


var is_main_menu_displaying := true
var shader_bubble_init_center := Vector2(0.5, 0.5)
var shader_bubble_center := Vector2(0.5, 0.5)
var shader_bubble_amplitude := Vector2(0.03, 0.07)


func _ready() -> void:
	DirtyDirtyUiManager.main_menu = self
	for node in get_tree().get_nodes_in_group("game_overlay"):
		node.hide()
	hide_death_menu()


func _process(delta: float) -> void:
	if is_main_menu_displaying:
		var shader = bubble_shader.material
		var time = Time.get_ticks_msec() / 1000.0
		shader_bubble_center.x = shader_bubble_init_center.x + sin(time) * shader_bubble_amplitude.x
		shader_bubble_center.y = shader_bubble_init_center.y + cos(time * 0.5) * shader_bubble_amplitude.y
		(shader as ShaderMaterial).set_shader_parameter("effect_center", shader_bubble_center)


func trigger_death_menu():
	you_died.modulate.a = 0
	black_background.modulate.a = 0
	you_died.show()
	black_background.show()
	await fade_in(you_died, 2.5)
	await fade_in(black_background, 2)
	await get_tree().create_timer(3).timeout
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
