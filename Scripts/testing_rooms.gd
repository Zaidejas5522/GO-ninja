extends StaticBody2D

# ============================================================
# ROOM TRANSITION STRESS TEST
# ============================================================
@export var transition_interval := 0.5          # seconds between room transitions
@export var max_transitions := 50               # safety cap (stop after N transitions)
@export var stop_on_memory_exceed := true
@export var max_memory_mb := 100.0

# ============================================================
# INTERNAL STATE
# ============================================================
var world: Node2D                     # the root node (room manager)
var player: CharacterBody2D
var transition_timer: float = 0.0
var transition_count := 0
var active := false
var last_direction_forward := true    # alternate between forward/back? we'll just go forward

# ============================================================
# LIFECYCLE
# ============================================================
func _ready():
	# Find world (the scene root, which has the room manager script)
	world = get_tree().current_scene
	if not world or not world.has_method("_load_room") and not world.has_method("_on_door_entered"):
		push_error("World node does not have room manager methods. Attach this script to the root of World.tscn?")
		return
	
	var players = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		push_error("No player found. Add player to group 'player'.")
		return
	player = players[0]
	
	print("Room transition stress test ready. Press F2 to start (transition every %.1f sec)." % transition_interval)

func _input(event):
	if event.is_action_pressed("ui_f2"):
		if active:
			stop_test()
		else:
			start_test()

# ============================================================
# PUBLIC METHODS
# ============================================================
func start_test():
	if active:
		return
	active = true
	transition_count = 0
	transition_timer = 0.0
	print("Starting room transition stress test. Will transition every %.1f seconds." % transition_interval)
	log_performance("Start")

func stop_test():
	if not active:
		return
	active = false
	print("Room transition stress test stopped after %d transitions." % transition_count)
	log_performance("Final")

func _process(delta):
	if not active:
		return
	
	# Check memory limit
	if stop_on_memory_exceed:
		var mem_mb = Performance.get_monitor(Performance.MEMORY_STATIC) / (1024.0 * 1024.0)
		if mem_mb >= max_memory_mb:
			stop_test()
			print("Stopped due to memory > %.1f MB" % max_memory_mb)
			return
	
	transition_timer += delta
	if transition_timer >= transition_interval:
		transition_timer = 0.0
		_perform_transition()

func _perform_transition():
	if not active:
		return
	
	# Try to trigger ExitDoor (forward transition)
	# First find current room
	var current_room = null
	if world.has_method("get_current_room"):
		current_room = world.get_current_room()
	else:
		# fallback: world.current_room if exposed
		current_room = world.current_room if "current_room" in world else null
	
	if not current_room:
		push_error("Cannot find current room.")
		return
	
	# Find ExitDoor in current room
	var exit_door = current_room.find_child("ExitDoor", true, false)
	if not exit_door:
		push_error("ExitDoor not found in current room. Can't transition.")
		return
	
	# Emit body_entered signal (simulate player touching door)
	# The door expects a body (player) and possibly an Area2D? Actually your _on_door_entered expects body, area.
	# In your room manager, _on_door_entered(body, area) is connected to exit_door.body_entered.
	# So we emit with player and door.
	exit_door.body_entered.emit(player)
	
	transition_count += 1
	print("Transition %d triggered." % transition_count)
	
	# Log performance every 10 transitions
	if transition_count % 10 == 0:
		log_performance("After %d transitions" % transition_count)
	
	# Check max transitions
	if max_transitions > 0 and transition_count >= max_transitions:
		stop_test()
		print("Reached maximum transitions (%d)." % max_transitions)

func log_performance(tag: String):
	var fps = Performance.get_monitor(Performance.TIME_FPS)
	var process_ms = Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	var physics_ms = Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0
	var memory_mb = Performance.get_monitor(Performance.MEMORY_STATIC) / (1024.0 * 1024.0)
	var objects = Performance.get_monitor(Performance.OBJECT_COUNT)
	
	var report = "=== %s ===\n" % tag
	report += "Transitions: %d\n" % transition_count
	report += "FPS: %.1f\n" % fps
	report += "Process: %.2f ms\n" % process_ms
	report += "Physics: %.2f ms\n" % physics_ms
	report += "Memory: %.2f MB\n" % memory_mb
	report += "Total objects: %d" % objects
	
	print(report)
	push_warning(report)
