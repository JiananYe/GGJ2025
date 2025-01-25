extends Control

@onready var hp_bar: ProgressBar = $HPBar
@onready var mana_bar: ProgressBar = $ManaBar

var entity: Entity

func _ready() -> void:
	if not entity:
		return
		
	hp_bar.max_value = entity.max_hp
	hp_bar.value = entity.current_hp
	
	if entity.has_method("get_mana"):
		mana_bar.max_value = entity.max_mana
		mana_bar.value = entity.current_mana
	else:
		mana_bar.visible = false

func _process(_delta: float) -> void:
	if not entity:
		return
		
	hp_bar.value = entity.current_hp
	if entity.has_method("get_mana"):
		mana_bar.value = entity.current_mana 
