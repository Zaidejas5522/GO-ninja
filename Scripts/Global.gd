extends Node

var PlayerHealth = 2



#POTENTIAL STUFF IS IN WEAPON SCRIPT WHEN A BODY ENTERS AREA 2D AND CURRENT IS IN PROCESS METHOD
var MaxPlayerHealth = 3
var PotentialPlayerHealth = 0
var CurrentItemHealth = 0

var PlayerSpeed = 130
var PotentialPlayerSpeed = 0
var CurrentItemSpeed = 0

var PlayerDamage = 3
var PotentialPlayerDamage = 0
var CurrentItemDamage = 0


#----
var WeaponSlot = 0
var IsHovering = false
#----

var SkillReady = true
var SkillCooldown = 10.0
var CurrentSkillCooldown = 0

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
