extends Node2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var bar: ProgressBar = $ProgressBar

func _process(delta: float) -> void:
	if Global.SkillReady:
		sprite.play("Active")
	else:
		sprite.play("Disabled")
	bar.max_value=Global.SkillCooldown
	bar.value = Global.CurrentSkillCooldown
