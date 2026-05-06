extends Node


var PlayerHealth = 40
var IsDamagable = false
var OtherAttacking = false
var Money = 0



#POTENTIAL STUFF IS IN WEAPON SCRIPT WHEN A BODY ENTERS AREA 2D AND CURRENT IS IN PROCESS METHOD
var MaxPlayerHealth = 40
var PotentialPlayerHealth = 0
var CurrentItemHealth = 0

var PlayerSpeed = 130
var PotentialPlayerSpeed = 0
var CurrentItemSpeed = 0

var PlayerDamage = 10
var PotentialPlayerDamage = 0
var CurrentItemDamage = 0


#----
var WeaponSlot = 0
var MaxSlot = 2
var IsHovering = false
#----

var SkillReady = true
var SkillCooldown = 5
var CurrentSkillCooldown = 0

var ShieldActive = 0



func _addHealth(ItemHealth):
	MaxPlayerHealth+=ItemHealth
	PlayerHealth+=ItemHealth
func _minusHealth(ItemHealth):
	MaxPlayerHealth-=ItemHealth
	if(PlayerHealth>MaxPlayerHealth):
		PlayerHealth=MaxPlayerHealth
		
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
	PlayerHealth=40
	MaxPlayerHealth=40
	PlayerSpeed=130
	PlayerDamage=10
	Money=0
	IsHovering = false
	WeaponSlot = 0
	CurrentItemDamage = 0
	PotentialPlayerDamage = 0
	OtherAttacking = false
	IsDamagable = false
	ShieldActive = 0
	SkillReady = true
	CurrentSkillCooldown = 0
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")
	
	print("New run started. All progress reset")
var debounce_timer: SceneTreeTimer = null

func _input(event):
	if event is InputEventKey and event.keycode == KEY_F11 and event.pressed:
		toggle_fullscreen_safe()

func toggle_fullscreen_safe():
	if debounce_timer: return  # still cooling down
	
	var current_mode = DisplayServer.window_get_mode()
	if current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	debounce_timer = get_tree().create_timer(0.3)
	await debounce_timer.timeout
	debounce_timer = null
