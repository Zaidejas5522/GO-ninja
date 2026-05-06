extends Button

func _ready():
	self.pressed.connect(_on_restart_pressed)

func _on_restart_pressed():
	Global.start_new_run() 
