extends TileMapLayer


enum WORLDS {
	FOREST,
	UNDEAD
}

enum TILE_TYPE {
	GRASS,
	GROUND,
	WATER
}

const NOISE_THRESHOLDS := [
	Vector2(-0.4, 0.3), # Grass
	Vector2(0.3, 1), # Ground
	Vector2(-1, -0.3) # Water
]
const WORLD_TILESET_COORDINATES := [
	[Vector2i(1, 1), Vector2(1, 4)], # Forest
	[Vector2i(2, 2), Vector2(2, 9)] # Undead
]
const TILE_SIZE := 16
const CHUNK_SIZE := Vector2i(40, 23) # (640 x 360) / 16


var current_tileset: int = WORLDS.FOREST


func _ready() -> void:
	randomize()
	load_chunk(0, 0)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_up"):
		populate_map()


func load_chunk(x, y) -> void:
	populate_map()


func populate_map() -> void:
	var noise := FastNoiseLite.new()
	noise.seed = Time.get_ticks_msec()
	noise.frequency = 0.04
	for y in range(CHUNK_SIZE.y):
		for x in range(CHUNK_SIZE.x):
			var noise_value := noise.get_noise_2d(x, y)
			if is_in_threshold(NOISE_THRESHOLDS[TILE_TYPE.GRASS], noise_value):
				set_cell(Vector2i(x, y), current_tileset, WORLD_TILESET_COORDINATES[current_tileset][TILE_TYPE.GRASS])
			if is_in_threshold(NOISE_THRESHOLDS[TILE_TYPE.GROUND], noise_value):
				set_cell(Vector2i(x, y), current_tileset, WORLD_TILESET_COORDINATES[current_tileset][TILE_TYPE.GROUND])
			if is_in_threshold(NOISE_THRESHOLDS[TILE_TYPE.WATER], noise_value):
				pass


func is_in_threshold(threshold: Vector2, value: float) -> bool:
	return value > threshold.x && value < threshold.y


func switch_world(world: int) -> void:
	pass
