extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	Transitioner.transition()
	await Transitioner.on_transition_finished
	get_tree().change_scene_to_file("res://Scenes/World.tscn")


func _on_settings_pressed() -> void:
	print("Options pressed. Not implemented yet (maybe never idk)")


func _on_exit_pressed() -> void:
	get_tree().quit()
