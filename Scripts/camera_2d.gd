extends Camera2D

@onready var player = get_node("../CharacterBody2D")

const H = 648
const W = 1152

func _ready():
	# Labai svarbu: kamera turi žiūrėti nuo kampo, ne nuo centro
	anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	position = Vector2(0, 0)

func _process(_delta):
	if player:
		# Paskaičiuojam, kuriame kambaryje stovi robotukas
		var room_index = floor(player.position.y / H)
		
		# Sklandžiai perstumiam vaizdą į to kambario viršų
		var target_y = room_index * H
		position.y = lerp(position.y, target_y, 0.15)
		position.x = 0
