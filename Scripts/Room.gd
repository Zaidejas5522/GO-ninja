extends Node2D

func _ready():
	# Kai žaidimas prasideda, šis kambarys pasislepia
	visible = true

# Šią funkciją iškviesime vėliau, kai žaidėjas įžengs į kambarį
func discover_room():
	visible = true


func _on_detection_area_body_entered(body: Node2D) -> void:
	discover_room()
	
	# cia veliau
	# if body.name == "Player":
	# discover_room()
