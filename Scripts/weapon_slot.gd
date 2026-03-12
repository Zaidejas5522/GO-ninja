extends Node2D
@onready var weapon_sprite: AnimatedSprite2D = $WeaponSprites

var MaxSlots = 2
var slots = 0
var currentslot = 0
var weapons = ["", ""]
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	Global.WeaponSlot = currentslot
	if Input.is_action_just_pressed("Switch"):
		# Cycle through slots
		switch_to_next_weapon()
		
	if weapons[currentslot] == "":
		weapon_sprite.visible=false
	else:
		weapon_sprite.visible = true
		weapon_sprite.play(str(weapons[currentslot]))
		
		
func addSlot():
	MaxSlots += 1
	weapons.append("")
		
func addWeapon(weapon):
	for i in range(MaxSlots):
		if weapons[i] == "":
			weapons[i] = str(weapon)
			slots+=1
			return i
	return -1  # Inventory full
func minusWeapon(taken_slot):
	if taken_slot >= 0 and taken_slot < MaxSlots:
		slots-=1
		weapons[taken_slot] = ""
	
	
	
	
func switch_to_next_weapon():
	var start_slot = currentslot
	var found = false
	
	# Search for the next occupied slot (skip empty slots)
	for i in range(MaxSlots):
		currentslot = (currentslot + 1) % MaxSlots
		if weapons[currentslot] != "":
			found = true
			break
	
	# If no occupied slot found, revert to the original slot
	if not found:
		currentslot = start_slot
