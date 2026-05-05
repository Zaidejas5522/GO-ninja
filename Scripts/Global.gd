extends Node


var PlayerHealth = 100
var IsDamagable = false
var OtherAttacking = false
var Money = 0



#POTENTIAL STUFF IS IN WEAPON SCRIPT WHEN A BODY ENTERS AREA 2D AND CURRENT IS IN PROCESS METHOD
var MaxPlayerHealth = 100
var PotentialPlayerHealth = 0
var CurrentItemHealth = 0

var PlayerSpeed = 130
var PotentialPlayerSpeed = 0
var CurrentItemSpeed = 0

var PlayerDamage = 5000
var PotentialPlayerDamage = 0
var CurrentItemDamage = 0


#----
var WeaponSlot = 0
var IsHovering = false
#----

var SkillReady = true
var SkillCooldown = 2
var CurrentSkillCooldown = 0

var ShieldActive = 0

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


#UI STUFF (RESET VARIABLES AFTER GANE OVER)
func start_new_run():
	PlayerHealth=30
	MaxPlayerHealth=30
	PlayerSpeed=130
	PlayerDamage=10
	Money=0
	
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")
	
	print("New run started. All progress reset")
