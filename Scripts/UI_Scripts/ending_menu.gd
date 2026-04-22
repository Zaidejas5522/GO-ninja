extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_next_level_pressed() -> void:
	print("no next level just yet.")


func _on_restart_level_pressed() -> void:
	Transitioner.transition()
	await Transitioner.on_transition_finished
	get_tree().change_scene_to_file("res://Scenes/World.tscn")


func _on_options_pressed() -> void:
	print("not implemented yet.")


func _on_exit_pressed() -> void:
	get_tree().quit()
