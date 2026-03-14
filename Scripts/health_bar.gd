extends Node2D
@onready var HealthBar: ProgressBar = $ProgressBar
@onready var label: Label = $ProgressBar/Label

#func _process(delta: float) -> void:
	#HealthBar.max_value=Global.MaxPlayerHealth
	#HealthBar.value=Global.PlayerHealth
	
func set_health_bar(health, maxHealth):
	HealthBar.max_value = maxHealth
	HealthBar.value = health
	
	label.text = str(health)
	
func change_health(newValue):
	HealthBar.value += newValue
	label.text = str(HealthBar.value)
