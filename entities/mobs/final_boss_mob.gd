extends BossMob
class_name FinalBossMob

const PROJECTILE_BURST_COUNT = 12  # Anzahl der Projektile in alle Richtungen

@onready var boss_health_bar: ProgressBar

func _ready() -> void:
	super._ready()
	# Verstärkte Boss-Statistiken
	max_hp *= 3.0  # Noch mehr HP als normaler Boss
	current_hp = max_hp
	movement_speed = 120.0  # Noch langsamer aber tankiger
	experience_value = 500.0  # Massive EXP-Belohnung
	projectile_attack_range = 600.0

	setup_boss_health_bar()

func setup_boss_health_bar() -> void:
	# Verstecke die normale HP-Bar
	hp_bar.hide()
	
	# Erstelle einen neuen CanvasLayer für die UI-Ebene
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100  # Stelle sicher, dass es über allem anderen liegt
	add_child(canvas_layer)
	
	# Erstelle die Boss-HP-Leiste
	boss_health_bar = ProgressBar.new()
	boss_health_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	boss_health_bar.position = Vector2(0, 20)
	boss_health_bar.custom_minimum_size = Vector2(800, 30)
	boss_health_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Styling der HP-Leiste
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.2, 0.2, 0.2, 0.8)
	bg_style.corner_radius_top_left = 4
	bg_style.corner_radius_top_right = 4
	bg_style.corner_radius_bottom_right = 4
	bg_style.corner_radius_bottom_left = 4
	
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color(0.8, 0.1, 0.1, 1.0)
	fill_style.corner_radius_top_left = 4
	fill_style.corner_radius_top_right = 4
	fill_style.corner_radius_bottom_right = 4
	fill_style.corner_radius_bottom_left = 4
	
	boss_health_bar.add_theme_stylebox_override("background", bg_style)
	boss_health_bar.add_theme_stylebox_override("fill", fill_style)
	
	boss_health_bar.max_value = max_hp
	boss_health_bar.value = current_hp
	boss_health_bar.show_percentage = false
	
	# Füge die HP-Leiste zum CanvasLayer hinzu
	canvas_layer.add_child(boss_health_bar)
	
	# Erstelle den Boss Namen
	var boss_name = Label.new()
	boss_name.text = "Skelly the Strong"
	boss_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_name.position = Vector2(0, -30)  # Über der HP-Leiste
	boss_name.custom_minimum_size = Vector2(800, 30)
	boss_name.add_theme_font_size_override("font_size", 24)
	boss_name.add_theme_color_override("font_color", Color(1, 0.8, 0, 1))  # Goldene Farbe
	
	canvas_layer.add_child(boss_name)

func take_hit(damage: float, damage_type: String = "physical") -> float:
	var final_damage = super.take_hit(damage, damage_type)
	if boss_health_bar:
		boss_health_bar.value = current_hp
	return final_damage

func projectile_attack() -> void:
	if !can_use_projectile:
		return
		
	can_use_projectile = false
	
	# Schieße Projektile in alle Richtungen
	for i in range(PROJECTILE_BURST_COUNT):
		var angle = (2 * PI * i) / PROJECTILE_BURST_COUNT
		var direction = Vector2(cos(angle), sin(angle))
		skill_manager.use_skill("projectile_attack", self)
	
	await get_tree().create_timer(projectile_cooldown).timeout
	can_use_projectile = true 
