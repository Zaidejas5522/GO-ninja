extends Node

var PlayerHealth = 2
var MaxPlayerHealth = 3

var PlayerSpeed = 130

var PlayerDamage = 3

#----
var WeaponSlot = 0
#----

func _addHealth(ItemHealth):
	MaxPlayerHealth+=ItemHealth
func _minusHealth(ItemHealth):
	MaxPlayerHealth-=ItemHealth
		
func _addSpeed(ItemSpeed):
	PlayerSpeed+=ItemSpeed
func _minusSpeed(ItemSpeed):
	PlayerSpeed-=ItemSpeed

func _addDamage(ItemDamage):
	PlayerDamage+=ItemDamage
func _minusDamage(ItemDamage):
	PlayerDamage-=ItemDamage

	
	
