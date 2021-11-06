extends Control
var grupo : ButtonGroup

func _ready():
	grupo = $"Bot canal".group


func presionado():
	get_tree().current_scene.config["Type"] = true if grupo.get_pressed_button().name  == "Bot canal" else false
	
	get_parent().add_child(load("res://Setup scenes/Bot_functions.tscn" if get_tree().current_scene.config["Type"] else "res://Setup scenes/Bot_registration.tscn").instance())
	queue_free()
	

func _on_Bot_canal_pressed():
	$Advertencia.popup_centered()
