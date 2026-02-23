extends Node2D
@onready var HealthBar: ProgressBar = $ProgressBar

func _process(delta: float) -> void:
	HealthBar.max_value=Global.MaxPlayerHealth
	HealthBar.value=Global.PlayerHealth
	
