extends Node

var PlayerHealth = 2
var MaxPlayerHealth = 3

var PlayerSpeed = 130

var PlayerDamage = 3

func _addHealth(ItemHealth):
	MaxPlayerHealth+=ItemHealth
	PlayerHealth+=ItemHealth
func _minusHealth(ItemHealth):
	MaxPlayerHealth-=ItemHealth
	if PlayerHealth>MaxPlayerHealth:
		PlayerHealth=MaxPlayerHealth
		
func _addSpeed(ItemSpeed):
	PlayerSpeed+=ItemSpeed
func _minusSpeed(ItemSpeed):
	PlayerSpeed-=ItemSpeed

func _addDamage(ItemDamage):
	PlayerDamage+=ItemDamage
func _minusDamage(ItemDamage):
	PlayerDamage-=ItemDamage

	
	
