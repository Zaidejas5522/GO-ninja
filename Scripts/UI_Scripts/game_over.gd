extends Control

@onready var game_over_sfx: AudioStreamPlayer2D = $GameOverSFX
@onready var exit_sfx: AudioStreamPlayer2D = $ExitSFX
@onready var button_sfx: AudioStreamPlayer2D = $ButtonSFX

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_over_sfx.play()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_exit_pressed() -> void:
	exit_sfx.play()
	await exit_sfx.finished
	get_tree().quit()


func _on_restart_pressed() -> void:
	button_sfx.play()
	Transitioner.transition()
	await Transitioner.on_transition_finished
	Global.start_new_run()
