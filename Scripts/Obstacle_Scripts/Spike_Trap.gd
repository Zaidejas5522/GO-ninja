extends Area2D

#@onready var HealthBar: ProgressBar = $ProgressBar
@onready var timer = $Timer

var speed_multi = 0.25

var target_player = null
var dmg = 5

func _ready():
	timer.timeout.connect(_on_timer_timeout)

func _on_body_entered(body: Node2D) -> void:
	
	if body is CharacterBody2D: #and "Global.PlayerHealth" in body:
		print("hp: ", Global.PlayerHealth)
		target_player = body
		target_player.SPEED *= speed_multi
		deal_damage()
		timer.start()

func _on_body_exited(body: Node2D) -> void:
	if body == target_player:
		target_player.SPEED /= speed_multi
		target_player = null
		timer.stop()

func _on_timer_timeout():
	deal_damage()

func deal_damage():
	if target_player:
		#Global.PlayerHealth -= dmg
		target_player.take_damage(dmg)
		print("hp after hit: ", Global.PlayerHealth)
