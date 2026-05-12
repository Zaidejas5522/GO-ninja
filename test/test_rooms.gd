extends GdUnitTestSuite

const WORLD_SCENE := "res://Scenes/World.tscn"

func get_world(runner) -> Node2D:
	await get_tree().process_frame
	var world = runner.scene()
	if world == null:
		push_error("World node not found")
	return world

func get_player(runner) -> CharacterBody2D:
	await get_tree().process_frame
	var player : CharacterBody2D = runner.find_child("Player", true, false)
	if player == null:
		push_error("Player node not found")
	return player

func get_current_room(world: Node2D) -> Node2D:
	return world.current_room

func get_door(room: Node2D, door_name: String) -> Area2D:
	return room.find_child(door_name, true, false)

func simulate_door_enter(world: Node2D, runner, door_name: String) -> void:
	var room := get_current_room(world)
	var door := get_door(room, door_name)
	assert_bool(door != null).override_failure_message("Door %s not found" % door_name)
	if door == null:
		return
	var player := await get_player(runner)
	if player:
		door.body_entered.emit(player)

# -----------------------------------------------------------------------------
# Tests
# -----------------------------------------------------------------------------

func test_initial_room_loads_start_room() -> void:
	var runner := scene_runner(WORLD_SCENE)
	var world := await get_world(runner)
	assert_bool(world != null)
	
	var current_room := get_current_room(world)
	assert_bool(current_room != null)
	assert_str(current_room.name).contains("StartRoom")
	
	var player := await get_player(runner)
	if player:
		var door_enter := current_room.find_child("DoorEnter", true, false)
		if door_enter:
			assert_vector(player.global_position).is_equal_approx(door_enter.global_position, Vector2(1,1))

func test_load_each_room_explicitly() -> void:
	var runner := scene_runner(WORLD_SCENE)
	var world := await get_world(runner)
	var player := await get_player(runner)
	assert_bool(world != null and player != null)
	
	var expected_rooms = [
		"StartRoom",
		"RoomCorridor",
		"CombatRoom",
		"TreasureRoom",
		"BossRoom"
	]
	
	for i in range(expected_rooms.size()):
		world._load_room(i, player, true)
		await get_tree().process_frame
		var current_room = get_current_room(world)
		assert_str(current_room.name).contains(expected_rooms[i])
		
		var spawn_point = current_room.find_child("DoorEnter", true, false)
		if spawn_point:
			assert_vector(player.global_position).is_equal_approx(spawn_point.global_position, Vector2(1,1))

func test_door_transition_no_enemies_moves_to_next_room() -> void:
	var runner := scene_runner(WORLD_SCENE)
	var world := await get_world(runner)
	var initial_room := get_current_room(world)
	var initial_index = world.current_room_index
	
	await simulate_door_enter(world, runner, "ExitDoor")
	await await_millis(500)
	
	var new_room := get_current_room(world)
	assert_bool(new_room != initial_room)
	assert_int(world.current_room_index).is_equal(initial_index + 1)
	assert_int(world.history_stack.size()).is_equal(1)
	assert_int(world.history_stack.back()).is_equal(initial_index)

func test_back_door_returns_to_previous_room() -> void:
	var runner := scene_runner(WORLD_SCENE)
	var world := await get_world(runner)
	
	await simulate_door_enter(world, runner, "ExitDoor")
	await await_millis(500)
	var after_forward = world.current_room_index
	
	await simulate_door_enter(world, runner, "BackDoor")
	await await_millis(500)
	
	assert_int(world.current_room_index).is_equal(0)
	assert_int(world.history_stack.size()).is_equal(0)
	assert_int(world.future_stack.size()).is_equal(1)

func test_local_teleport_between_doors() -> void:
	var runner := scene_runner(WORLD_SCENE)
	var world := await get_world(runner)
	var player := await get_player(runner)
	assert_bool(player != null)
	
	var room := get_current_room(world)
	var local_door_a := room.find_child("LocalDoorA", true, false)
	var local_door_b := room.find_child("LocalDoorB", true, false)
	
	if local_door_a == null or local_door_b == null:
		push_warning("Local doors not present in current room, skipping test")
		return
	
	var spawn_b := room.find_child("SpawnPointB", true, false)
	var spawn_a := room.find_child("SpawnPointA", true, false)
	assert_bool(spawn_b != null and spawn_a != null)
	
	player.global_position = local_door_a.global_position + Vector2(5,5)
	world._on_local_teleport(player, "SpawnPointB")
	await get_tree().process_frame
	assert_vector(player.global_position).is_equal_approx(spawn_b.global_position, Vector2(1,1))
	
	world._on_local_teleport(player, "SpawnPointA")
	await get_tree().process_frame
	assert_vector(player.global_position).is_equal_approx(spawn_a.global_position, Vector2(1,1))



func test_end_condition_triggers_ending_scene() -> void:
	var runner := scene_runner(WORLD_SCENE)
	var world := await get_world(runner)
	var player := await get_player(runner)
	
	world._load_room(4, player, true)
	await get_tree().process_frame
	assert_int(world.current_room_index).is_equal(4)
	
	await simulate_door_enter(world, runner, "ExitDoor")
	await await_millis(500)
	assert_bool(world.is_changing_room).is_false()

func test_door_signals_connected_on_room_load() -> void:
	var runner := scene_runner(WORLD_SCENE)
	var world := await get_world(runner)
	
	var room := get_current_room(world)
	var exit_door := get_door(room, "ExitDoor")
	var back_door := get_door(room, "BackDoor")
	var local_a := get_door(room, "LocalDoorA")
	var local_b := get_door(room, "LocalDoorB")
	
	if exit_door:
		assert_bool(exit_door.body_entered.is_connected(world._on_door_entered))
	if back_door:
		assert_bool(back_door.body_entered.is_connected(world._on_door_entered))
	if local_a:
		assert_bool(local_a.body_entered.is_connected(world._on_local_teleport))
	if local_b:
		assert_bool(local_b.body_entered.is_connected(world._on_local_teleport))
