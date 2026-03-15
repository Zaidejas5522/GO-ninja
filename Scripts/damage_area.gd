extends Area2D

var entered = false #ziuri ar kunas buvo iejes ar ne
var hasattacked = false #ziuri ar buvo padares ataka
var realbody = "" #keepina track of the body


#Deti take damage i body entered biski negerai nes tik viena karta triggerina kai ieina ir jei lieki prie prieso toliau tavo ataku neregistruoja
#tai as pakeiciau I process, tipo gal yra geresniu metodu su signalais bet as tingejau lol

func _on_body_entered(body):
	print(body.name)
	entered = true
	if body.has_method("take_damage"):
		realbody = body


func _on_body_exited(body):
	entered = false

	
#pirmai zaidejas turedavo iseiti ir vel ieiti kad triggerintusi ataka tai padariau kad paatakuotu 
#ir trigerintusi overtime vel jei jis yra tenais
func _process(delta: float) -> void:  
	if entered and hasattacked == false:
		realbody.take_damage(15)
		hasattacked = true
		await get_tree().create_timer(2).timeout
		hasattacked = false
		
