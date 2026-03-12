extends Node

var PlayerHealth = 2
var MaxPlayerHealth = 3



func _addHealth(ItemHealth):
	MaxPlayerHealth+=ItemHealth
	PlayerHealth+=ItemHealth
func _minusHealth(ItemHealth):
	MaxPlayerHealth-=ItemHealth
	if PlayerHealth>MaxPlayerHealth:
		PlayerHealth=MaxPlayerHealth
	
	
