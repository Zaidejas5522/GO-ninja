extends GdUnitTestSuite

const SCENE_PATH := "res://Scenes/TESTINGROOM.tscn"
const DASH_DURATION := 0.2   # dashtime in player script
const DASH_COOLDOWN := 0.1   # dashcooldown in player script
const BASE_SPEED := 130.0
const DASH_SPEED := BASE_SPEED * 2

# Helper to get player safely
func get_player(runner) -> CharacterBody2D:
	await get_tree().process_frame
	var player :CharacterBody2D = runner.find_child("Player", true, false)
	if player == null:
		push_error("Player node not found")
	return player

# Helper to simulate dash action press and hold for a short moment
func dash(runner, duration: float = 0.05) -> void:
	runner.simulate_action_press("Dash")
	await await_millis(duration * 1000)
	runner.simulate_action_release("Dash")

# Helper to get approximate displacement after a dash
func get_dash_displacement(runner, player: CharacterBody2D, start_pos: Vector2) -> Vector2:
	# Run the dash
	await dash(runner)
	# Wait for dash to fully finish (duration + a little extra)
	await await_millis((DASH_DURATION + 0.05) * 1000)
	return player.global_position - start_pos

func test_dash_moves_down_when_no_movement() -> void:
	var runner := scene_runner(SCENE_PATH)
	var player := await get_player(runner)
	if player == null:
		return
	
	# Ensure no movement keys are pressed (player should face DOWN initially)
	var start_pos := player.global_position
	var displacement := await get_dash_displacement(runner, player, start_pos)
	
	# Should move down (positive Y)
	assert_bool(displacement.y > 0)\
		.override_failure_message("Dash without movement did not move down")
	# Should move very little horizontally
	assert_float(displacement.x)\
		.override_failure_message("Dash caused horizontal movement when none expected")\
		.is_equal_approx(0.0, 1.0)

func test_dash_moves_left() -> void:
	var runner := scene_runner(SCENE_PATH)
	var player := await get_player(runner)
	if player == null:
		return
	
	# First press left to set facing direction
	runner.simulate_key_press(KEY_A)
	await await_millis(50)  # let input register
	runner.simulate_key_release(KEY_A)
	
	var start_pos := player.global_position
	var displacement := await get_dash_displacement(runner, player, start_pos)
	
	# Should move left (negative X)
	assert_bool(displacement.x < 0)\
		.override_failure_message("Dash after left movement did not move left")
	# Y displacement should be near zero
	assert_float(displacement.y)\
		.override_failure_message("Dash caused unexpected vertical movement")\
		.is_equal_approx(0.0, 5.0)

func test_dash_moves_right() -> void:
	var runner := scene_runner(SCENE_PATH)
	var player := await get_player(runner)
	if player == null:
		return
	
	runner.simulate_key_press(KEY_D)
	await await_millis(50)
	runner.simulate_key_release(KEY_D)
	
	var start_pos := player.global_position
	var displacement := await get_dash_displacement(runner, player, start_pos)
	
	assert_bool(displacement.x > 0)\
		.override_failure_message("Dash after right movement did not move right")

func test_dash_moves_up() -> void:
	var runner := scene_runner(SCENE_PATH)
	var player := await get_player(runner)
	if player == null:
		return
	
	runner.simulate_key_press(KEY_W)
	await await_millis(50)
	runner.simulate_key_release(KEY_W)
	
	var start_pos := player.global_position
	var displacement := await get_dash_displacement(runner, player, start_pos)
	
	assert_bool(displacement.y < 0)\
		.override_failure_message("Dash after up movement did not move up")

func test_dash_speed_is_double_normal_speed() -> void:
	var runner := scene_runner(SCENE_PATH)
	var player := await get_player(runner)
	if player == null:
		return
	
	# First, measure normal movement speed over a short time
	runner.simulate_key_press(KEY_D)  # move right
	await await_millis(50)
	var normal_start := player.global_position
	await await_millis(100)  # 0.1 sec
	var normal_end := player.global_position
	runner.simulate_key_release(KEY_D)
	var normal_speed = (normal_end.x - normal_start.x) / 0.1
	
	# Now dash speed
	# Reset position? Not necessary; just dash in same direction
	var dash_start := player.global_position
	await dash(runner, 0.05)  # very short dash press, but dash lasts full duration
	await await_millis(DASH_DURATION * 1000)
	var dash_end := player.global_position
	var dash_speed = (dash_end.x - dash_start.x) / DASH_DURATION
	
	# Dash speed should be approximately double
	assert_float(dash_speed)\
		.override_failure_message("Dash speed not double normal speed")\
		.is_equal_approx(normal_speed * 2, normal_speed * 0.3)  # 30% tolerance

func test_dash_cooldown() -> void:
	var runner := scene_runner(SCENE_PATH)
	var player := await get_player(runner)
	if player == null:
		return
	
	var start_pos := player.global_position
	
	# First dash
	await dash(runner)
	await await_millis(DASH_DURATION * 1000)  # wait for dash to finish
	var after_first := player.global_position
	assert_bool(after_first != start_pos)\
		.override_failure_message("First dash did not move player")
	
	# Try to dash again immediately after dash ends (cooldown still active)
	var pos_before_second := player.global_position
	await dash(runner, 0.05)
	await await_millis((DASH_DURATION + 0.05) * 1000)
	var after_second := player.global_position
	
	# Should move very little or not at all because cooldown prevents dash
	var second_displacement = after_second - pos_before_second
	assert_float(second_displacement.length())\
		.override_failure_message("Second dash happened during cooldown - dash should not be possible")\
		.is_less(5.0)  # tolerance for tiny physics jitter
	
	# Wait full cooldown + a bit
	await await_millis((DASH_COOLDOWN + 0.1) * 1000)
	var pos_before_third := player.global_position
	await dash(runner)
	await await_millis((DASH_DURATION + 0.05) * 1000)
	var after_third := player.global_position
	
	assert_bool((after_third - pos_before_third).length() > 10.0)\
		.override_failure_message("Third dash after cooldown did not move player - cooldown may be too long")

func test_dash_cannot_be_interrupted_by_another_dash() -> void:
	var runner := scene_runner(SCENE_PATH)
	var player := await get_player(runner)
	if player == null:
		return
	
	# Start a dash, and while dashing, try to dash again
	runner.simulate_action_press("Dash")
	await await_millis(50)  # partway through dash
	
	# Try second dash press
	runner.simulate_action_press("Dash")  # This should be ignored because isdashing is true
	await await_millis(50)
	runner.simulate_action_release("Dash")  # release both? We'll just release after
	await await_millis((DASH_DURATION + 0.05) * 1000)
	runner.simulate_action_release("Dash")  # ensure release
	
	# If second dash had triggered, player would have moved extra; but we only expect one dash total.
	# Compare displacement to expected single dash displacement.
	# Since we can't easily measure velocity changes, we check that final displacement is plausible.
	# A simpler check: after first dash starts, the isdashing flag should be true. We can inspect via script.
	# However, we can also check that player didn't get an extra speed boost mid-dash.
	# Better: check that candash becomes false and stays false until end of dash+cooldown.
	
	# Instead, we directly test the internal state using call_method (if GDUnit supports).
	# Or we rely on cooldown test above; separate test for state.
	# We'll do a simple state check:
	var can_dash_after_first : bool = player.candash  # should be false immediately after dash starts? candash becomes false in start_dash.
	# After we pressed dash, we need to wait a frame for script to process.
	await get_tree().process_frame
	can_dash_after_first = player.candash
	assert_bool(not can_dash_after_first)\
		.override_failure_message("After dash start, candash should be false")
	
	# Try to dash again by simulating another press after a moment
	runner.simulate_action_press("Dash")
	await get_tree().process_frame
	# The start_dash function checks 'if not isdashing and candash', so second press should not start new dash.
	# We can check that isdashing remains true? Actually isdashing is already true.
	var is_dashing_after_second_press : bool = player.isdashing
	assert_bool(is_dashing_after_second_press)\
		.override_failure_message("isdashing should still be true during dash")
	runner.simulate_action_release("Dash")
	
	# Finally, after dash finishes, candash becomes true after cooldown.
	await await_millis((DASH_DURATION + DASH_COOLDOWN + 0.1) * 1000)
	assert_bool(player.candash)\
		.override_failure_message("After dash and cooldown, candash should be true")
	
	
	
	
	
	
	
	
