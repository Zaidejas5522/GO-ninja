extends Area2D

var speed_multiplier = 0.3 

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and "SPEED" in body:
		body.SPEED *= speed_multiplier
		print("stuck, speed multiplied: ", speed_multiplier)

func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D and "SPEED" in body:
		body.SPEED /= speed_multiplier
		print("free")
