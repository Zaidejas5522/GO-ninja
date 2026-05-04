extends Area2D

func _ready() -> void:
	pass
func _enter_tree():
	for child in get_children():
		if child is Area2D:
			child.isShop = 1
