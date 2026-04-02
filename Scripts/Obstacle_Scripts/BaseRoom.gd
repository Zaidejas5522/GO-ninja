extends TileMapLayer

enum RoomType { COMBAT, TREASURE, START, EMPTY }
@export var current_type: RoomType = RoomType.EMPTY
var traps = {
	"sand": preload("res://Scenes/Obstacles/QuickSand.tscn"),
	"spike": preload("res://Scenes/Obstacles/SpikeTrap.tscn"),
	"shuriken": preload("res://Scenes/Obstacles/ShurikenMoving.tscn")
}

func _ready():
	await get_tree().process_frame
	if current_type != RoomType.START and current_type != RoomType.EMPTY:
		generate_traps()

func generate_traps():
	var floor_layer = get_tree().get_first_node_in_group("floors")
	if not floor_layer: return
	
	var cells = floor_layer.get_used_cells()
	cells.shuffle()
	
	for i in range(5):
		var pos = cells.pop_front()
		var world_pos = floor_layer.map_to_local(pos)
		
		spawn_random_trap(world_pos)

func spawn_random_trap(pos: Vector2):
	var type = traps.keys().pick_random()
	
	if current_type == RoomType.TREASURE:
		type = "sand"
	
	var item = traps[type].instantiate()
	add_child(item)
	item.position=pos
	
