extends Node2D
@onready var HealthBar: ProgressBar = $ProgressBar

#func _process(delta: float) -> void:
	#HealthBar.max_value=Global.MaxPlayerHealth
	#HealthBar.value=Global.PlayerHealth
	
func set_health_bar(health, maxHealth):
	HealthBar.max_value = maxHealth
	HealthBar.value = health
	
func change_health(newValue):
	HealthBar.value += newValue
