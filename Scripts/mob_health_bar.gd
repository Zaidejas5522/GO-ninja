extends ProgressBar

#func set_mob_health_bar(health):
	#value = health
#func change_health(newValue):
	#value += newValue
func _ready() -> void:
	max_value=$"..".health
func _process(delta: float) -> void:
	value=$"..".health
