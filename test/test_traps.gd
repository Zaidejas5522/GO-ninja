extends GdUnitTestSuite

const TESTING_ROOM := "res://Scenes/TESTINGROOM.tscn"

func get_player(runner) -> CharacterBody2D:
	await get_tree().process_frame
	var player = runner.find_child("Player", true, false)
	assert_bool(player != null).override_failure_message("Player not found").is_true()
	return player

func teleport_player_into_trap(player: CharacterBody2D, trap: Area2D) -> void:
	# Get trap's collision shape center
	var collision = trap.find_child("CollisionShape2D", true, false)
	var trap_center = trap.global_position
	if collision and collision.shape:
		if collision.shape is RectangleShape2D:
			trap_center += collision.shape.size / 2
		elif collision.shape is CircleShape2D:
			trap_center += Vector2(collision.shape.radius, collision.shape.radius)
	# Move player right into the trap
	player.global_position = trap_center
	# Force multiple physics frames to ensure overlap detection
	for i in range(3):
		await get_tree().physics_frame

# -----------------------------------------------------------------------------
# QuickSandTrap
# -----------------------------------------------------------------------------
func test_quicksand_slows_player() -> void:
	var runner := scene_runner(TESTING_ROOM)
	var player := await get_player(runner)
	var quicksand := runner.find_child("QuickSandTrap", true, false)
	assert_bool(quicksand != null).is_true()
	
	var original_speed = player.SPEED
	
	# Teleport into trap and wait for signal to be processed
	await teleport_player_into_trap(player, quicksand)
	# Additional small delay to ensure _on_body_entered runs
	await await_millis(50)
	
	var expected_speed = original_speed * 0.3
	assert_float(player.SPEED)\
		.override_failure_message("QuickSand did not slow player (expected %s, got %s)" % [expected_speed, player.SPEED])\
		.is_equal_approx(expected_speed, 0.1)
	
	# Move out and verify speed restoration
	var exit_pos = quicksand.global_position + Vector2(300, 0)
	player.global_position = exit_pos
	await get_tree().physics_frame
	await await_millis(50)
	assert_float(player.SPEED)\
		.override_failure_message("Speed not restored after leaving quicksand")\
		.is_equal_approx(original_speed, 0.1)

# -----------------------------------------------------------------------------
# SpikeTrap
# -----------------------------------------------------------------------------
func test_spike_trap_slows_and_damages() -> void:
	var runner := scene_runner(TESTING_ROOM)
	var player := await get_player(runner)
	var spike := runner.find_child("SpikeTrap", true, false)
	assert_bool(spike != null).is_true()
	
	var original_health = Global.PlayerHealth
	var original_speed = player.SPEED
	
	await teleport_player_into_trap(player, spike)
	await await_millis(50)  # let first damage and slow apply
	
	# Speed should be reduced
	assert_float(player.SPEED)\
		.override_failure_message("Spike trap did not slow player")\
		.is_equal_approx(original_speed * 0.25, 0.1)
	
	# Damage should have been applied at least once
	assert_int(Global.PlayerHealth)\
		.override_failure_message("Spike trap did not damage player")\
		.is_less(original_health)
	
	# Wait for another timer tick (assume timer interval = 1 sec)
	await await_millis(1100)
	assert_int(Global.PlayerHealth)\
		.override_failure_message("Spike trap did not apply periodic damage")\
		.is_less(original_health - 5)  # at least 10 damage total
	
	# Move out and verify speed restoration
	var exit_pos = spike.global_position + Vector2(300, 0)
	player.global_position = exit_pos
	await get_tree().physics_frame
	await await_millis(50)
	assert_float(player.SPEED)\
		.override_failure_message("Speed not restored after leaving spike trap")\
		.is_equal_approx(original_speed, 0.1)
	
	# Restore health for other tests
	Global.PlayerHealth = original_health

# -----------------------------------------------------------------------------
# ShurikenMoving
# -----------------------------------------------------------------------------
func test_shuriken_damages_player() -> void:
	var runner := scene_runner(TESTING_ROOM)
	var player := await get_player(runner)
	var shuriken := runner.find_child("ShurikenMoving", true, false)
	assert_bool(shuriken != null).is_true()
	
	var original_health = Global.PlayerHealth
	
	# Place player in the shuriken's path (to the left, assuming it moves left)
	var shuriken_pos = shuriken.global_position
	var player_pos = shuriken_pos + Vector2(-30, 0)
	player.global_position = player_pos
	await get_tree().physics_frame
	
	# Let shuriken move for a short time to collide
	var time_to_collide = 0.2  # seconds (speed 150 -> moves 30 units)
	await await_millis(time_to_collide * 1000)
	
	assert_int(Global.PlayerHealth)\
		.override_failure_message("Shuriken did not damage player")\
		.is_less(original_health)
	
	# Restore health
	Global.PlayerHealth = original_health
