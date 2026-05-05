extends Node2D
@onready var HealthBar: ProgressBar = $ProgressBar
@onready var label: Label = $Label

func _process(delta: float) -> void:
	HealthBar.max_value=Global.MaxPlayerHealth
	HealthBar.value=Global.PlayerHealth
	label.text=str(int(Global.PlayerHealth)) + "/" + str(int(Global.MaxPlayerHealth))
#func set_health_bar(health, maxHealth):
	#HealthBar.max_value = maxHealth
	#HealthBar.value = health
	
#func change_health(newValue):
	#HealthBar.value += newValue
