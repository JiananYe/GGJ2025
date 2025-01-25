class_name MainMenu
extends Control


@onready var death_menu: Control = $DeathMenu
@onready var black_background: Panel = $DeathMenu/BlackBackground
@onready var you_died: MarginContainer = $DeathMenu/YouDied


func _ready() -> void:
	DirtyDirtyUiManager.main_menu = self
	hide_death_menu()


func _process(delta: float) -> void:
	pass


func trigger_death_menu():
	you_died.modulate.a = 0
	black_background.modulate.a = 0
	you_died.show()
	black_background.show()
	await fade_in(you_died, 2.5)
	await fade_in(black_background, 2)


func fade_in(node: CanvasItem, duration: float) -> void:
	var time_passed := 0.0
	while time_passed < duration:
		time_passed += get_process_delta_time()
		node.modulate.a = time_passed / duration
		await get_tree().process_frame


func hide_death_menu():
	black_background.modulate.a = 0
	you_died.modulate.a = 0
