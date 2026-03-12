extends Node

var start_room_scene = preload("res://Scenes/StartRoom.tscn")
var combat_room_scene = preload("res://Scenes/CombatRoom.tscn")
var treasure_room_scene = preload("res://Scenes/TreasureRoom.tscn")
var boss_room_scene = preload("res://Scenes/BossRoom.tscn")

#var previous_room_scene = null # praeito kambario save
var current_room = null
var is_changing_room = false
var is_boss_defeated = true # true for now, kol testinu

var history_stack=[]
var future_stack=[]

@onready var fade_rect = $CanvasLayer/FadeRect

func _ready() -> void:
	randomize()
	current_room = start_room_scene.instantiate()
	current_room.set_meta("scene_ref", start_room_scene)
	add_child(current_room)
	current_room.position = Vector2(0, 0)
	_setup_door_signals(current_room)
	
	var player = get_node_or_null("CharacterBody2D")
	if player:
		player.position = Vector2(200, 200)

func _setup_door_signals(room):
	var all_areas = room.find_children("*", "Area2D")
	for area in all_areas:
		if area.is_in_group("doors"):
			if area.body_entered.is_connected(_on_door_entered):
				area.body_entered.disconnect(_on_door_entered)
			area.body_entered.connect(_on_door_entered.bind(area))

func _on_door_entered(body, area):
	if is_changing_room or not body is CharacterBody2D:
		return
	#if current_room.name.contains("BossRoom") and not is_boss_defeated:
		#return

	is_changing_room = true
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.15)
	tween.tween_callback(_change_room.bind(body, area))
	tween.tween_property(fade_rect, "modulate:a", 0.0, 0.15)
	tween.tween_callback(func(): is_changing_room = false)

func _change_room(body, area):
	var old_room = current_room
	var next_scene = null
	#var new_room=next_scene.instantiate()
	#new_room.set_meta("scene_ref", next_scene)
	#add_child(new_room)
	var going_north=area.name.contains("North")
	var going_south=area.name.contains("South")
	
	var current_scene_ref=_get_room_ref(old_room)
	
	# ejimas atgal (north durys)
	if going_north:
		if history_stack.size()>0:
			#saugom dabartini kambari del future, kad atgal tuo paciu route eitu gryzt
			future_stack.append(current_scene_ref)
			#pasiimam kambari is history
			next_scene=history_stack.pop_back()
			print("gryzimas atgal. dar liko: ", history_stack.size())
		else:
			print("start room")
			is_changing_room=false
			return
	#judejimas i prieki *(South durys)
	elif going_south:
		#dabartini kambari i history ikraunam
		history_stack.append(current_scene_ref)
		
		if future_stack.size()>0:
			next_scene=future_stack.pop_back()
			print("einam i jau lankyta rooma")
		else:
			next_scene=_generate_random_next_room(old_room.name)
			print("generuojam nauja room")
			future_stack.clear()

	if next_scene:
		var new_room = next_scene.instantiate()
		new_room.set_meta("scene_ref", next_scene)
		add_child(new_room)
		new_room.position = Vector2(0, 0)
		current_room = new_room
		
		_setup_door_signals(new_room)
		
		# Teleportacija
		if going_south:
			body.position=Vector2(200,60) #kad virsuj spawn
		else:
			body.position=Vector2(200,340) #kad apacioj spawn (del uztikrinimo, kad nesispawnintu uz ribu kambario)
		old_room.queue_free()
	else:
		is_changing_room=false
		
func _get_room_ref(room_node: Node):
	# get_meta kad nemestų klaidos, jei neranda
	var ref = room_node.get_meta("scene_ref", null)
	if ref != null:
		return ref
	
	# jei neranda, gryztam prie pavadinimo tikrinimo
	var r_name = room_node.name.to_lower()
	if "start" in r_name: return start_room_scene
	if "combat" in r_name: return combat_room_scene
	if "boss" in r_name: return boss_room_scene
	if "treasure" in r_name: return treasure_room_scene
	
	return start_room_scene
	
func _generate_random_next_room(current_name):
	var roll=randf()
	if current_name.contains("StartRoom"):
		return treasure_room_scene if roll<=0.10 else combat_room_scene
	elif current_name.contains("BossRoom"):
		return treasure_room_scene if roll<=0.40 else start_room_scene
	else:
		if roll<=0.15:return treasure_room_scene
		elif roll<=0.25:return boss_room_scene
		else:return combat_room_scene
