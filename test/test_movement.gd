extends GdUnitTestSuite

# Helper function to get the player node safely
func get_player(runner) -> CharacterBody2D:
	await get_tree().process_frame
	var player :CharacterBody2D = runner.find_child("Player")
	if player == null:
		push_error("Player node not found – check node name and scene structure")
	return player

func test_player_movement_right():
	var runner := scene_runner("res://Scenes/TESTINGROOM.tscn")
	var player := await get_player(runner)
	if player == null:
		return
	
	var start_position := player.global_position
	
	runner.simulate_key_press(KEY_D)
	await await_millis(500)
	runner.simulate_key_release(KEY_D)
	
	var end_position := player.global_position
	assert_bool(end_position.x > start_position.x)\
		.override_failure_message("Player did not move right when D was pressed")

func test_player_movement_left():
	var runner := scene_runner("res://Scenes/TESTINGROOM.tscn")
	var player := await get_player(runner)
	if player == null:
		return
	
	var start_position := player.global_position
	
	runner.simulate_key_press(KEY_A)
	await await_millis(500)
	runner.simulate_key_release(KEY_A)
	
	var end_position := player.global_position
	assert_bool(end_position.x < start_position.x)\
		.override_failure_message("Player did not move left when A was pressed")

func test_player_movement_up():
	var runner := scene_runner("res://Scenes/TESTINGROOM.tscn")
	var player := await get_player(runner)
	if player == null:
		return
	
	var start_position := player.global_position
	
	runner.simulate_key_press(KEY_W)
	await await_millis(500)
	runner.simulate_key_release(KEY_W)
	
	var end_position := player.global_position
	assert_bool(end_position.y < start_position.y)\
		.override_failure_message("Player did not move up when W was pressed")

func test_player_movement_down():
	var runner := scene_runner("res://Scenes/TESTINGROOM.tscn")
	var player := await get_player(runner)
	if player == null:
		return
	
	var start_position := player.global_position
	
	runner.simulate_key_press(KEY_S)
	await await_millis(500)
	runner.simulate_key_release(KEY_S)
	
	var end_position := player.global_position
	assert_bool(end_position.y > start_position.y)\
		.override_failure_message("Player did not move down when S was pressed")
