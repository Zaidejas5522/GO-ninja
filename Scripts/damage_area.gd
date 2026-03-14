extends Area2D

func _on_body_entered(body):
	print(body.name)
	if body.has_method("take_damage"):
		body.take_damage(15)
