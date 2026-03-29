extends TileMapLayer

enum RoomType { COMBAT, TREASURE, START, EMPTY }
var quicksand_scene = preload("res://Scenes/Obstacles/QuickSand.tscn")
@export var current_type: RoomType = RoomType.EMPTY

func _ready():
	await get_tree().process_frame
	setup_room(current_type)

func setup_room(type: RoomType):
	randomize()
	if type == RoomType.START or type == RoomType.EMPTY: return

	# 1. grindu plyteles, bet cia reikia patikrint dar.
	var floor_tiles = get_used_cells().filter(func(pos):
		var data = get_cell_tile_data(pos)
		return data and data.get_custom_data_by_layer_id(0) == true
	)
	
	# 2. filtering kurios close to doors (safety zone)
	var doors = get_tree().get_nodes_in_group("doors")
	floor_tiles = floor_tiles.filter(func(pos):
		var world_pos = to_global(map_to_local(pos))
		for door in doors:
			if world_pos.distance_to(door.global_position) < 100: return false
		return true
	)

	# 3. amount ir shuffling
	floor_tiles.shuffle()
	var trap_count = randi_range(2, 4) if type == RoomType.COMBAT else randi_range(1, 3)
	
	# 4. Spawnam su atstumo tikrinimu tarp pačių trapsu
	var spawned_positions = []
	for i in range(trap_count):
		if floor_tiles.is_empty(): break
		
		var pos = floor_tiles.pop_front()
		var world_pos = map_to_local(pos)
		
		# check ar ne too close kitu traps
		var too_close = spawned_positions.any(func(p): return world_pos.distance_to(p) < 80)
		
		if not too_close:
			spawn_obstacle(pos)
			spawned_positions.append(world_pos)

func spawn_obstacle(pos: Vector2i):
	var trap = quicksand_scene.instantiate()
	trap.position = map_to_local(pos)
	
	# archetype
	if current_type == RoomType.TREASURE:
		trap.modulate = Color.DIM_GRAY
		trap.set("speed_multiplier", 0.1)
	else:
		trap.modulate = Color.BISQUE
		trap.set("speed_multiplier(0.5)", 0.5)
		
	add_child(trap)
