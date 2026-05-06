extends Node2D

var current_room = null
var current_room_index = 0 # Pradedame nuo StartRoom (indeksas 0)
var history_stack = []     # Saugo buvusių kambarių indeksus
var future_stack = []      # Saugo future kambarių indeksus (grįžimui)
var is_changing_room = false

const _ROOM_PRELOADS = [
	preload("res://Scenes/Rooms/StartRoom.tscn"),
	preload("res://Scenes/Rooms/RoomCorridor.tscn"),
	preload("res://Scenes/Rooms/CombatRoom.tscn"),
	preload("res://Scenes/Rooms/TreasureRoom.tscn"),
	preload("res://Scenes/Rooms/BossRoom.tscn")
]
# room sequence
@onready var room_sequence = [
	"res://Scenes/Rooms/StartRoom.tscn",
	"res://Scenes/Rooms/RoomCorridor.tscn",
	"res://Scenes/Rooms/CombatRoom.tscn",
	"res://Scenes/Rooms/TreasureRoom.tscn",
	"res://Scenes/Rooms/BossRoom.tscn"
]

func _ready():
	for child in get_children():
		if "Room" in child.name:
			current_room = child
			break
			
	var player = get_node_or_null("CharacterBody2D")
	
	if current_room == null:
		_load_room(0, player)
	else:
		_setup_door_signals(current_room)
		if player:
			await get_tree().process_frame
			var start_point = current_room.find_child("DoorEnter", true, false)
			if start_point:
				player.global_position = start_point.global_position
				print("veikia")

func _setup_door_signals(room):
	# ExitDoor (Eiti gilyn)
	var exit = room.find_child("ExitDoor", true, false)
	if exit and not exit.body_entered.is_connected(_on_door_entered):
		exit.body_entered.connect(_on_door_entered.bind(exit))
		
	# BackDoor (Grįžti atgal)
	var back = room.find_child("BackDoor", true, false)
	if back and not back.body_entered.is_connected(_on_door_entered):
		back.body_entered.connect(_on_door_entered.bind(back))

	var localA = room.find_child("LocalDoorA", true, false)
	if localA and not localA.body_entered.is_connected(_on_local_teleport):
		localA.body_entered.connect(_on_local_teleport.bind("SpawnPointB"))
		
	var localB = room.find_child("LocalDoorB", true, false)
	if localB and not localB.body_entered.is_connected(_on_local_teleport):
		localB.body_entered.connect(_on_local_teleport.bind("SpawnPointA"))
		
		
func _on_local_teleport(body, target_marker_name):
	print("duris touchino: ", body.name)
	
	if body is CharacterBody2D:
		var target = current_room.find_child(target_marker_name, true, false)
		if target:
			body.global_position = target.global_position
			
			if "current_axis" in body:
				body.current_axis = ""
				print("veikia: ", body.name, "tp'ed i ", target_marker_name)
		
		# kolkas taip, del enemies triggerinimo (nepamirst patikrint veliau)
func _on_local_door_entered(body, target_marker_name):
	# checkas ar playeris ar enemy group object
	if body.name == "CharacterBody2D" or body.is_in_group("enemy"):
		var target = current_room.find_child(target_marker_name, true, false)
		
		if target:
			body.global_position = target.global_position
			
			if "current_axis" in body:
				body.current_axis = ""
				
			print("tp: ", body.name, " to ", target_marker_name)

func _on_door_entered(body, area):
	# 1. Patikrinam ar tai žaidėjas
	if body.name == "CharacterBody2D" and not is_changing_room:
		
		var enemies = get_tree().get_nodes_in_group("enemy")
		
		if enemies.size() > 0:
			print("enemies", enemies.size(), " durys locked")
			return # SUSTABDAu VISKĄ ČIA
			
		# Jei priešų nėra - keičiam kambarį
		is_changing_room = true
		call_deferred("_change_room", body, area)

func _change_room(body, area):
	var next_index = -1
	var going_deeper = (area.name == "ExitDoor")
	
	if going_deeper:
		if future_stack.size() > 0:
			history_stack.append(current_room_index)
			next_index = future_stack.pop_back()
		elif current_room_index < room_sequence.size() - 1:
			history_stack.append(current_room_index)
			next_index = current_room_index + 1
	else:
		# jei grįžtame atgal
		if history_stack.size() > 0:
			future_stack.append(current_room_index)
			next_index = history_stack.pop_back()

	if next_index != -1:
		_load_room(next_index, body, going_deeper)
	else:
		Transitioner.transition()
		await Transitioner.on_transition_finished
		get_tree().change_scene_to_file("res://Scenes/UI/EndingMenu.tscn")
		is_changing_room = false

func _load_room(index, player = null, deeper = true):
	var path = room_sequence[index]
	if ResourceLoader.exists(path):
		var next_scene = load(path)
		var new_room = next_scene.instantiate()
		
		# addinam new room
		add_child(new_room)
		
		# tp žaidėją ant atitinkamo markerio
		if player:
			var spawn_name = "DoorEnter" if deeper else "DoorReturn"
			var spawn_point = new_room.find_child(spawn_name, true, false)
			if spawn_point:
				player.global_position = spawn_point.global_position
				print("tp'ed to: ", spawn_name)
		
		# removinam old room
		if current_room:
			current_room.queue_free()
		
		current_room = new_room
		current_room_index = index
		
		# patikrint dar
		call_deferred("_setup_door_signals", new_room)
		print("success: uzkrautas kambariuks: ", path)
	else:
		print("nera failo: ", path)
	
	# cia del, to kad nepersoktu iskart i kita room
	await get_tree().create_timer(0.3).timeout
	is_changing_room = false
