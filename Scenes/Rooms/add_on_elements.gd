extends TileMapLayer

var quicksand_scene = preload("res://Scenes/Obstacles/QuickSand.tscn")

# kitiem roomam, kad also butu traps?
enum RoomType { COMBAT, TREASURE, EMPTY }

func spawn_obstacle(pos: Vector2i):
	# sukuriame scenos copy
	var obstacle = quicksand_scene.instantiate()
	
	add_child(obstacle)
	
	# movinam į reikiamą vietą
	# map_to_local paverčia koords (pvz. 5,5) į ekrano taškus
	obstacle.position = map_to_local(pos)

func setup_room(type: RoomType):
	if type == RoomType.COMBAT:
		spawn_obstacle(Vector2i(18,7))
		spawn_obstacle(Vector2i(5,5))
		print("traps vejkia")
	elif type == RoomType.TREASURE:
		spawn_obstacle(Vector2i(5,2))
		print("acargei")

func _ready():
	setup_room(RoomType.COMBAT)
	setup_room(RoomType.TREASURE)
