extends GdUnitTestSuite

const WORLD_SCENE := "res://Scenes/World.tscn"

const ENEMY_SCENES := [
	"res://Scenes/Enemies/bear.tscn",
	"res://Scenes/Enemies/DemonSamurai.tscn",
	"res://Scenes/Enemies/KappaGreen.tscn",
	"res://Scenes/Enemies/Lizard.tscn",
	"res://Scenes/Enemies/Reptile.tscn",
	"res://Scenes/Enemies/Skull.tscn",
]
func test_print_works():
	print("Hello from GDUnit")
	push_warning("This is a warning")
	assert_bool(true).is_true()
func get_world(runner) -> Node2D:
	await get_tree().process_frame
	var world = runner.scene()
	assert_bool(world != null).override_failure_message("World not found").is_true()
	return world

func get_current_room(world: Node2D) -> Node2D:
	return world.current_room

func spawn_enemy(world: Node2D, room: Node2D, enemy_path: String, position: Vector2) -> CharacterBody2D:
	var enemy_scene = load(enemy_path)
	if enemy_scene == null:
		push_error("Cannot load: " + enemy_path)
		return null
	var enemy = enemy_scene.instantiate()
	room.add_child(enemy)
	enemy.global_position = position
	enemy.add_to_group("enemy")
	return enemy

# Helper to move player in a square pattern
func move_player_in_square(player: CharacterBody2D, center: Vector2, size: float, duration: float, steps: int) -> void:
	var corners = [
		center + Vector2(-size, -size),
		center + Vector2( size, -size),
		center + Vector2( size,  size),
		center + Vector2(-size,  size),
	]
	var step_time = duration / steps
	for i in range(steps):
		var t = float(i) / steps
		var corner_index = int(t * 4) % 4          # Convert to int before modulo
		var next_index = (corner_index + 1) % 4
		var local_t = (t * 4) - corner_index
		var pos = corners[corner_index].lerp(corners[next_index], local_t)
		player.global_position = pos
		await get_tree().physics_frame
		if i % 10 == 0:
			await wait_for_fps_report()

func wait_for_fps_report():
	# Small delay to let performance metrics stabilize
	await await_millis(100)

func log_performance(iteration: int, total_enemies: int):
	var fps = Performance.get_monitor(Performance.TIME_FPS)
	var process_time = Performance.get_monitor(Performance.TIME_PROCESS)
	var physics_time = Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)
	var memory = Performance.get_monitor(Performance.MEMORY_STATIC)
	var objects = Performance.get_monitor(Performance.OBJECT_COUNT)
	
	var report = "=== Performance Report (Iteration %d, Enemies: %d) ===\n" % [iteration, total_enemies]
	report += "  FPS: %.1f\n" % fps
	report += "  Process time: %.3f ms\n" % (process_time * 1000)
	report += "  Physics time: %.3f ms\n" % (physics_time * 1000)
	report += "  Memory: %d KB\n" % (memory / 1024)
	report += "  Total objects: %d" % objects
	
	push_warning(report)
	

# -----------------------------------------------------------------------------
# Stress Tests
# -----------------------------------------------------------------------------

func test_spawn_many_enemies_and_move_player() -> void:
	"""Spawn 100 enemies and move player around to stress AI."""
	var runner := scene_runner(WORLD_SCENE)
	var world := await get_world(runner)
	var room := get_current_room(world)
	var player := runner.find_child("Player", true, false)
	assert_bool(player != null).is_true()
	
	var enemy_count := 100
	var enemy_path := ENEMY_SCENES[0]  # bear (or first type)
	var radius := 400.0
	var enemies: Array[Node] = []
	
	# Spawn enemies in a circle
	for i in range(enemy_count):
		var angle = i * (TAU / enemy_count)
		var pos = player.global_position + Vector2(cos(angle), sin(angle)) * radius
		var enemy = spawn_enemy(world, room, enemy_path, pos)
		if enemy:
			enemies.append(enemy)
	
	# Let enemies stabilize
	await await_millis(1000)
	log_performance(0, enemies.size())
	
	# Move player in a square to make enemies chase continuously
	var start_center = player.global_position
	var square_size = 600.0
	var total_duration = 8.0  # seconds
	var steps = 80  # number of movement updates
	
	await move_player_in_square(player, start_center, square_size, total_duration, steps)
	
	# Final performance check
	await await_millis(500)
	log_performance(1, enemies.size())
	
	# Assert that FPS didn't drop too low (adjust threshold as needed)
	var final_fps = Performance.get_monitor(Performance.TIME_FPS)
	assert_bool(final_fps > 20)\
		.override_failure_message("FPS too low after moving with %d enemies: %.1f" % [enemies.size(), final_fps])\
		.is_true()
	
	# Cleanup
	for enemy in enemies:
		enemy.queue_free()
	await get_tree().process_frame

func test_repeated_spawn_and_free_with_movement() -> void:
	"""Spawn waves of enemies while moving player to detect performance issues."""
	var runner := scene_runner(WORLD_SCENE)
	var world := await get_world(runner)
	var room := get_current_room(world)
	var player := runner.find_child("Player", true, false)
	
	var waves := 4
	var enemies_per_wave := 40
	var enemy_path := ENEMY_SCENES[0]
	var all_wave_enemies: Array[Node] = []
	
	var mem_baseline = Performance.get_monitor(Performance.MEMORY_STATIC)
	
	for wave in range(waves):
		var wave_enemies: Array[Node] = []
		# Spawn wave
		for i in range(enemies_per_wave):
			var pos = player.global_position + Vector2(randf_range(-400,400), randf_range(-400,400))
			var enemy = spawn_enemy(world, room, enemy_path, pos)
			if enemy:
				wave_enemies.append(enemy)
				all_wave_enemies.append(enemy)
		
		# Move player during this wave to increase AI load
		var center = player.global_position
		await move_player_in_square(player, center, 400.0, 3.0, 30)
		
		# Free this wave
		for enemy in wave_enemies:
			enemy.queue_free()
		await get_tree().process_frame
		
		log_performance(wave + 1, all_wave_enemies.size())
	
	# After all waves, ensure memory is cleaned up
	await await_millis(1000)
	var mem_final = Performance.get_monitor(Performance.MEMORY_STATIC)
	var mem_leak = mem_final - mem_baseline
	print("Total memory change after waves: %d KB" % (mem_leak / 1024))
	
	# Clean any remaining enemies
	for enemy in all_wave_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	
	assert_bool(mem_leak < 2 * 1024 * 1024)\
		.override_failure_message("Memory leak detected: %d bytes" % mem_leak)\
		.is_true()
