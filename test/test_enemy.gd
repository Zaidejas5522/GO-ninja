extends GdUnitTestSuite

const SCENE_PATH := "res://Scenes/TESTINGROOM.tscn"   # adjust to your actual world scene
const ENEMY_NODE_NAME := "Bear"                 # or whatever your enemy node is called
const PLAYER_GROUP := "player"

# Helper to get player safely
func get_player(runner) -> CharacterBody2D:
	await get_tree().process_frame
	var player :CharacterBody2D= runner.find_child("Player", true, false)
	if player == null:
		push_error("Player node not found")
	return player

# Helper to get enemy safely
func get_enemy(runner) -> CharacterBody2D:
	await get_tree().process_frame
	var enemy :CharacterBody2D= runner.find_child("Bear", true, false)
	if enemy == null:
		push_error("Enemy node not found")
	return enemy

# Helper to move the player to a specific position and wait a bit
func move_player_to(player: CharacterBody2D, target_pos: Vector2) -> void:
	player.global_position = target_pos
	# Force a few physics frames so breadcrumbs are updated
	for i in range(3):
		await get_tree().physics_frame

# Helper to get distance between two nodes
func distance_between(node1: Node2D, node2: Node2D) -> float:
	return node1.global_position.distance_to(node2.global_position)

func test_enemy_follows_player_using_breadcrumbs() -> void:
	var runner := scene_runner(SCENE_PATH)
	var player := await get_player(runner)
	var enemy := await get_enemy(runner)
	if player == null or enemy == null:
		return
	
	# Ensure player has breadcrumbs (triggered by movement)
	# Move player a bit to create some breadcrumbs
	var start_pos := Vector2(100, 100)
	var far_pos := Vector2(300, 200)
	move_player_to(player, start_pos)
	await get_tree().physics_frame
	
	# Record initial distance
	var initial_distance := distance_between(player, enemy)
	
	# Move player to a distant location; enemy should start moving
	move_player_to(player, far_pos)
	
	# Wait a few seconds for enemy to chase (using breadcrumbs)
	await await_millis(3000)
	
	var final_distance := distance_between(player, enemy)
	
	# Assert enemy got significantly closer (or at least moved)
	assert_bool(final_distance < initial_distance - 20.0)\
		.override_failure_message("Enemy did not reduce distance to player (initial: %s, final: %s)" % [initial_distance, final_distance])

func test_enemy_damages_player_when_in_contact() -> void:
	var runner := scene_runner(SCENE_PATH)
	var player := await get_player(runner)
	var enemy := await get_enemy(runner)
	if player == null or enemy == null:
		return
	
	# Record initial health (you need to expose health or use Global)
	# Assuming Global.PlayerHealth (as used in your player script)
	var initial_health = Global.PlayerHealth
	
	# Position enemy and player very close so damage area triggers
	var contact_pos := Vector2(500, 500)
	move_player_to(player, contact_pos)
	enemy.global_position = contact_pos + Vector2(5, 5)   # slightly offset but inside Area2D
	
	# Wait long enough for damage tick (2 seconds timeout in damage area)
	await await_millis(2100)   # a bit more than 2 seconds to ensure damage triggers
	
	var final_health = Global.PlayerHealth
	
	# Assert health decreased
	assert_bool(final_health < initial_health)\
		.override_failure_message("Player health did not decrease after enemy contact (initial: %s, final: %s)" % [initial_health, final_health])
	
	# Optional: check that damage is applied repeatedly (e.g., after another 2 seconds)
	await await_millis(2100)
	var final_health_again = Global.PlayerHealth
	assert_bool(final_health_again < final_health)\
		.override_failure_message("Player did not take damage again after 2 seconds")

func test_enemy_stops_moving_when_player_out_of_sight() -> void:
	# This test checks that after losing line of sight, the enemy goes to last known position
	var runner := scene_runner(SCENE_PATH)
	var player := await get_player(runner)
	var enemy := await get_enemy(runner)
	if player == null or enemy == null:
		return
	
	# Place player and enemy in line of sight (no obstacles)
	var start_pos := Vector2(200, 200)
	move_player_to(player, start_pos)
	enemy.global_position = Vector2(150, 200)
	await await_millis(1000)
	
	# Remember enemy's position when player visible
	await get_tree().physics_frame
	var pos_while_chasing := enemy.global_position
	
	# Place player behind a wall or far away out of raycast range? 
	# Simpler: temporarily remove player from group to break reference? Not ideal.
	# Instead, move player to a position where raycast cannot hit (e.g., behind a wall)
	# But for test simplicity, we can move player far away and wait for enemy to lose sight.
	var far_away := Vector2(2000, 2000)
	move_player_to(player, far_away)
	await await_millis(2000)   # enough time for enemy to lose sight and stop moving
	
	var final_pos := enemy.global_position
	
	# Enemy should have moved towards last known position, then stopped.
	# We just check final position is not too far from where it was when chasing.
	# This is a loose assertion - can be refined.
	var distance_moved := final_pos.distance_to(pos_while_chasing)
	assert_bool(distance_moved < 50.0)\
		.override_failure_message("Enemy kept moving after losing player (moved %s units)" % distance_moved)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
