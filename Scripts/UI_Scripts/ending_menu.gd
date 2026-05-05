extends Control

@onready var end_sfx: AudioStreamPlayer2D = $EndSFX
@onready var button_sfx: AudioStreamPlayer2D = $ButtonSFX
@onready var exit_sfx: AudioStreamPlayer2D = $ExitSFX

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	end_sfx.play()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_next_level_pressed() -> void:
	button_sfx.play()
	print("no next level just yet.")


func _on_restart_level_pressed() -> void:
	button_sfx.play()
	Transitioner.transition()
	await Transitioner.on_transition_finished
	Global.start_new_run()
	#get_tree().change_scene_to_file("res://Scenes/World.tscn")


func _on_options_pressed() -> void:
	button_sfx.play()
	print("not implemented yet.")


func _on_exit_pressed() -> void:
	exit_sfx.play()
	await exit_sfx.finished
	get_tree().quit()
