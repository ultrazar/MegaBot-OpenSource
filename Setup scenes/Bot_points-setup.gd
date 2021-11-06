extends Control
var temp
var nodo

func _ready():
	nodo = get_tree().current_scene

func _on_Canjeos_control_selected(button_data):
	temp = button_data
	$confirmacion.window_title = "Quieres seleccionar \" " + button_data["title"] + " \" ?"
	$confirmacion.popup_centered()



func _on_confirmacion_confirmed():
	nodo.config["points_reward"] = temp
	$Siguiente.disabled = false


func _on_Siguiente_pressed():
	nodo.acabar()
	queue_free()
