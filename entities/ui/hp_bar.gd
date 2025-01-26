extends ProgressBar

var entity: Entity

func _ready() -> void:
	if not entity:
		return
		
	max_value = entity.max_hp
	value = entity.current_hp

func _process(_delta: float) -> void:
	if not entity:
		return
		
	value = entity.current_hp
