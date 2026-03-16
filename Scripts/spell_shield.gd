extends Node2D
@onready var player = get_tree().get_first_node_in_group("player")


func _process(delta: float) -> void:
	global_position=player.global_position
	if Global.ShieldActive <= 0:
		queue_free()
