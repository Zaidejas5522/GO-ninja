extends Area2D

func _ready() -> void:
	for child in get_children():
		if child is Area2D:
			print("pakeista")
			child.isShop = 1
