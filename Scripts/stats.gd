extends Node2D
@onready var labelStrength: Label = $Strength/Label
@onready var label2Strength: Label = $Strength/Label2

@onready var labelHealth: Label = $Health/Label
@onready var label2Health: Label = $Health/Label2

@onready var labelSpeed: Label = $Speed/Label
@onready var label2Speed: Label = $Speed/Label2

@onready var slot = get_tree().get_first_node_in_group("WeaponSlot")

func _process(delta: float) -> void:
	# Update base stats
	labelStrength.text = str(Global.PlayerDamage).trim_suffix(".0")
	labelHealth.text = str(Global.MaxPlayerHealth).trim_suffix(".0")
	labelSpeed.text = str(round(Global.PlayerSpeed/10)).trim_suffix(".0")
	
	# Handle hover comparison only if inventory is full
	if slot.slots < slot.MaxSlots:
		# Inventory not full – hide all comparison labels
		label2Strength.visible = false
		label2Health.visible = false
		label2Speed.visible = false
	else:
		if Global.IsHovering:
			# Show comparison labels
			label2Strength.visible = true
			label2Health.visible = true
			label2Speed.visible = true
			
			# Strength comparison
			var strength_diff = Global.PotentialPlayerDamage - Global.CurrentItemDamage
			if strength_diff > 0:
				label2Strength.text = "+ " + str(strength_diff).trim_suffix(".0")
				label2Strength.modulate = Color.GREEN
			elif strength_diff < 0:
				label2Strength.text = "- " + str(-strength_diff).trim_suffix(".0")
				label2Strength.modulate = Color.RED
			
			
			# Health comparison
			var health_diff = Global.PotentialPlayerHealth - Global.CurrentItemHealth
			if health_diff > 0:
				label2Health.text = "+ " + str(health_diff).trim_suffix(".0")
				label2Health.modulate = Color.GREEN
			elif health_diff < 0:
				label2Health.text = "- " + str(-health_diff).trim_suffix(".0")
				label2Health.modulate = Color.RED
	
			
			# Speed comparison
			var speed_diff = Global.PotentialPlayerSpeed - Global.CurrentItemSpeed
			if speed_diff > 0:
				label2Speed.text = "+ " + str(round(speed_diff/10)).trim_suffix(".0")
				label2Speed.modulate = Color.GREEN
			elif speed_diff < 0:
				label2Speed.text = "- " + str(round(-speed_diff/10)).trim_suffix(".0")
				label2Speed.modulate = Color.RED
	
		else:
			# Not hovering – hide all comparison labels
			label2Strength.visible = false
			label2Health.visible = false
			label2Speed.visible = false
