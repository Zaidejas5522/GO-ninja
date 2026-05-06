extends Node2D

@onready var room_music: AudioStreamPlayer2D = $RoomMusic

func _ready():
	visible = true
	room_music.play()

func discover_room():
	visible = true


func _on_detection_area_body_entered(body: Node2D) -> void:
	discover_room()
	
	# cia veliau
	# if body.name == "Player":
	# discover_room()
