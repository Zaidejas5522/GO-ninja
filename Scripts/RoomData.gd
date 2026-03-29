extends Resource
class_name RoomData

@export var room_name: String = "Kambarys"
@export var room_scene: PackedScene 

@export_enum("Start", "Corridor", "Combat", "Treasure", "Boss") var type: String = "Combat"

@export_group("Doors")
@export var has_north: bool = false
@export var has_south: bool = false
@export var has_east: bool = false
@export var has_west: bool = false
