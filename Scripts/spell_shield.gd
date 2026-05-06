extends Node2D
@onready var player = get_tree().get_first_node_in_group("player")
@onready var shield_2: AudioStreamPlayer2D = $Shield2


func _process(delta: float) -> void:
	global_position=player.global_position
	if Global.ShieldActive <= 0:
		shield_2.play()
		await shield_2.finished
		queue_free()
