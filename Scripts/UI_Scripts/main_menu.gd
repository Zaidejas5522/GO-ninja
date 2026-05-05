extends Control

@onready var main_menu_sfx: AudioStreamPlayer2D = $MainMenuSFX
@onready var exit_sfx: AudioStreamPlayer2D = $ExitSFX
@onready var button_sfx: AudioStreamPlayer2D = $ButtonSFX

@onready var main_buttons: VBoxContainer = $MainButtons
@onready var options: Panel = $Options

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_menu_sfx.play()
	main_buttons.visible = true
	options.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	button_sfx.play()
	Transitioner.transition()
	await Transitioner.on_transition_finished
	get_tree().change_scene_to_file("res://Scenes/World.tscn")


func _on_settings_pressed() -> void:
	button_sfx.play()
	#print("Options pressed. Not implemented yet (maybe never idk)")
	main_buttons.visible = false
	options.visible = true

func _on_exit_pressed() -> void:
	exit_sfx.play()
	await exit_sfx.finished
	get_tree().quit()


func _on_back_options_pressed() -> void:
	button_sfx.play()
	_ready()
