extends Area2D

@onready var coin_sfx: AudioStreamPlayer2D = $CoinSFX

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
		
	Global.Money += 1
	coin_sfx.play()
	await coin_sfx.finished
	print("pinigas paimtas")
	queue_free()
