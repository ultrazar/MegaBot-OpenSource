extends Control



func presionado():
	var nodo = get_tree().current_scene
	
	nodo.config["puntos"] = true if $puntos.pressed else false
	nodo.config["automod pro"] = true if $automod.pressed else false
	if nodo.config["puntos"]: get_parent().add_child(preload("res://Setup scenes/Bot_authoritzation.tscn").instance())
	else: get_tree().change_scene("res://Panel de control/Main.tscn")
	queue_free()
