extends Node2D

# ============================================================
# STRESS TEST CONFIGURATION
# ============================================================
@export var enemy_scene_path := "res://Scenes/Enemies/bear.tscn"
@export var enemies_per_wave := 10
@export var spawn_radius := 150.0           # small radius around player
@export var move_radius := 200.0            # small circle for player movement
@export var wave_interval := 2.0            # seconds between spawning waves
@export var target_fps := 30.0              # stop when FPS drops to this value
@export var max_enemies := 500              # safety cap

# ============================================================
# INTERNAL STATE
# ============================================================
var player: CharacterBody2D
var spawned_enemies: Array[Node] = []
var moving := false
var spawning := false
var wave_timer: float = 0.0
var angle := 0.0

# ============================================================
# LIFECYCLE
# ============================================================
func _ready():
	var players = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		push_error("No player found. Add player to group 'player'.")
		return
	player = players[0] as CharacterBody2D
	print("PerformanceMonitor ready. Press F1 to start continuous stress test.")

func _input(event):
	if event.is_action_pressed("ui_f1"):
		start_stress_test()

# ============================================================
# PUBLIC METHODS
# ============================================================
func start_stress_test():
	if moving or spawning:
		print("Test already running.")
		return
	print("Starting continuous stress test. Will stop when FPS drops below %.1f." % target_fps)
	moving = true
	spawning = true
	wave_timer = wave_interval
	# Start player moving in a small circle
	_move_player_in_circle()

# ============================================================
# INTERNAL METHODS
# ============================================================
func _move_player_in_circle():
	var center = player.global_position
	var speed := 100.0          # movement speed in pixels per second
	var radius := move_radius
	var angular_speed := speed / radius   # radians per second
	var last_time := Time.get_ticks_msec() / 1000.0
	
	while moving and is_instance_valid(player):
		var now = Time.get_ticks_msec() / 1000.0
		var delta = now - last_time
		last_time = now
		angle += angular_speed * delta
		var new_pos = center + Vector2(cos(angle), sin(angle)) * radius
		player.global_position = new_pos
		await get_tree().physics_frame

func _process(delta):
	if not spawning:
		return
	
	# Check FPS and stop if too low
	var fps = Performance.get_monitor(Performance.TIME_FPS)
	if fps <= target_fps:
		_stop_test("FPS dropped to %.1f (below target %.1f)" % [fps, target_fps])
		return
	
	# Spawn waves periodically
	wave_timer -= delta
	if wave_timer <= 0.0:
		_spawn_wave()
		wave_timer = wave_interval

func _spawn_wave():
	if not spawning:
		return
	if spawned_enemies.size() >= max_enemies:
		_stop_test("Reached max enemy limit: %d" % max_enemies)
		return
	
	var room = get_current_room()
	if not room:
		room = get_tree().current_scene
	
	var wave_count = min(enemies_per_wave, max_enemies - spawned_enemies.size())
	for i in range(wave_count):
		var angle_deg = randf_range(0, TAU)
		var offset = Vector2(cos(angle_deg), sin(angle_deg)) * spawn_radius
		var enemy_scene = load(enemy_scene_path)
		if enemy_scene == null:
			push_error("Failed to load enemy scene: ", enemy_scene_path)
			return
		var enemy = enemy_scene.instantiate()
		room.add_child(enemy)
		enemy.global_position = player.global_position + offset
		enemy.add_to_group("enemy")
		spawned_enemies.append(enemy)
	
	print("Wave spawned. Total enemies: %d" % spawned_enemies.size())
	log_performance("After wave")

func _stop_test(reason: String):
	moving = false
	spawning = false
	print("Stress test stopped: ", reason)
	log_performance("Final")
	print("Cleaning up %d enemies..." % spawned_enemies.size())
	for enemy in spawned_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	spawned_enemies.clear()
	print("Cleanup complete.")

func log_performance(tag: String = ""):
	var fps = Performance.get_monitor(Performance.TIME_FPS)
	var process_ms = Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	var physics_ms = Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0
	var memory_kb = Performance.get_monitor(Performance.MEMORY_STATIC) / 1024
	var objects = Performance.get_monitor(Performance.OBJECT_COUNT)
	
	var report = "=== %s Performance ===\n" % [tag if tag != "" else "Stress Test"]
	report += "Enemies: %d\n" % spawned_enemies.size()
	report += "FPS: %.1f\n" % fps
	report += "Process: %.2f ms\n" % process_ms
	report += "Physics: %.2f ms\n" % physics_ms
	report += "Memory: %d KB\n" % memory_kb
	report += "Total objects: %d" % objects
	
	print(report)
	push_warning(report)

func get_current_room():
	var world = get_tree().current_scene
	if world.has_method("get_current_room"):
		return world.get_current_room()
	if world.has_node("CurrentRoom"):
		return world.get_node("CurrentRoom")
	return get_tree().current_scene
