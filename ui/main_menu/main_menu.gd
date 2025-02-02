class_name MainMenu
extends Control


@onready var passive_tree: PassiveTree = $CanvasLayer/PassiveTreeMenu
@onready var death_menu: Control = $CanvasLayer/DeathMenu
@onready var black_background: Panel = $CanvasLayer/DeathMenu/BlackBackground
@onready var you_died: MarginContainer = $CanvasLayer/DeathMenu/YouDied
@onready var bubble_shader: ColorRect = $CanvasLayer/MainMenu/CanvasLayer/TextureRect
@onready var bubble_sprite: Control = $CanvasLayer/MainMenu/BubbleSprite
@onready var settings_window: Window = $CanvasLayer/MainMenu/SettingsWindow
@onready var main_menu: Control = $CanvasLayer/MainMenu
@onready var main_main: Node2D = $"../"
@onready var event_emitter_player_death: AudioStreamPlayer = $CanvasLayer/DeathMenu/DeathScreen
@onready var event_emitter_music: AudioStreamPlayer = $ThemeMenu
@onready var event_emitter_music_game: AudioStreamPlayer = $BossFightMusicTry2

const level_scene = preload("res://scenes/Main.tscn")
var level: Node2D = null

var is_main_menu_displaying := true
var is_bubble_walking_in := false
var shader_bubble_init_center := Vector2(0.5, 0.4)
var shader_bubble_walk_in_speed := 0.3
var shader_bubble_walk_in_position := Vector2(0.5, 0.4)
var shader_bubble_center := Vector2(0.5, 0.5)
var shader_bubble_amplitude := Vector2(0.03, 0.04)
var bubble_transform_scale := 1



func _ready() -> void:
	event_emitter_music.play()
	
	DirtyDirtyUiManager.main_menu = self
	for node in get_tree().get_nodes_in_group("game_overlay"):
		node.hide()
	
	# Connect passive tree closed signal
	passive_tree.closed.connect(_on_passive_tree_closed)
	
	you_died.modulate.a = 0
	GameManager.set_process(false)


#func _process(delta: float) -> void:
	##if is_bubble_walking_in:
		##var distance = shader_bubble_center.y - shader_bubble_init_center.y
		##var easing_factor = (distance * 7) if distance < 0.1 else 1.0  # Ease only at the very end
		##shader_bubble_center.y -= shader_bubble_walk_in_speed * delta * easing_factor
		##move_shader_bubble_center(shader_bubble_center)
		##if shader_bubble_center.y <= shader_bubble_init_center.y:
			##is_bubble_walking_in = false
	##
	#if is_main_menu_displaying:
		#var time = Time.get_ticks_msec() / 1000.0
		#float_shader_bubble(time)



func trigger_death_menu():
	event_emitter_music_game.stop()
	event_emitter_player_death.play()
	you_died.modulate.a = 0
	black_background.modulate.a = 0
	you_died.show()
	for node in get_tree().get_nodes_in_group("game_overlay"):
		node.hide()
	black_background.show()
	GameManager.set_process(false)
	GameManager.reset()
	await fade_in(you_died, 2.5)
	await fade_in(black_background, 2)
	if level != null:
		level.queue_free()
	await fade_out(you_died, 2)
	event_emitter_music.stop()
	await fade_in(main_menu, 2)
	event_emitter_music.play()
	you_died.hide()
	main_menu.show()



func fade_in(node: CanvasItem, duration: float) -> void:
	var time_passed := 0.0
	while time_passed < duration:
		time_passed += get_process_delta_time()
		node.modulate.a = time_passed / duration
		await get_tree().process_frame


func fade_out(node: CanvasItem, duration: float) -> void:
	var time_passed := 0.0
	while time_passed < duration:
		time_passed += get_process_delta_time()
		node.modulate.a = 1 - time_passed / duration
		await get_tree().process_frame


func hide_death_menu():
	black_background.modulate.a = 0
	you_died.modulate.a = 0


func move_shader_bubble_center(pos: Vector2) -> void:
	var shader = bubble_shader.material
	(shader as ShaderMaterial).set_shader_parameter("effect_center", pos)
	bubble_sprite_follow_shader_bubble(pos)


func bubble_sprite_follow_shader_bubble(pos := Vector2.ZERO) -> void:
	var screen_size = get_viewport().size
	var x: float = screen_size.x * pos.x
	var y: float = screen_size.y * pos.y - bubble_sprite.size.y
	bubble_sprite.position = Vector2i(x, y)


func float_shader_bubble(time: float) -> void:
	var center_x = shader_bubble_center.x + sin(time) * shader_bubble_amplitude.x
	var center_y = shader_bubble_center.y + cos(time * 0.5) * shader_bubble_amplitude.y
	move_shader_bubble_center(Vector2(center_x, center_y))


func _on_button_quit_pressed() -> void:
	get_tree().quit()


func _on_button_play_pressed() -> void:
	event_emitter_music.stop()
	for node in get_tree().get_nodes_in_group("game_overlay"):
		node.show()
	main_menu.hide()
	level = level_scene.instantiate()
	main_main.add_child(level)
	GameManager.set_process(true)
	await fade_out(black_background, 1)
	event_emitter_music_game.play()


func _on_button_settings_pressed() -> void:
	settings_window.show()


func _on_h_slider_value_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))


func _on_settings_window_close_requested() -> void:
	settings_window.hide()


func _on_button_passive_tree_pressed() -> void:
	main_menu.hide()
	passive_tree.show()


func _on_passive_tree_closed() -> void:
	main_menu.show()
