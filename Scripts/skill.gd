extends Node2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var bar: ProgressBar = $ProgressBar
@onready var skill_sfx: AudioStreamPlayer2D = $SkillSFX


var was_skill_ready: bool = true

func _process(delta: float) -> void:
	if was_skill_ready == false and Global.SkillReady == true:
		skill_sfx.play()
	
	was_skill_ready = Global.SkillReady
	
	if Global.SkillReady:
		sprite.play("Active")
	else:
		sprite.play("Disabled")
	bar.max_value=Global.SkillCooldown
	bar.value = Global.CurrentSkillCooldown
