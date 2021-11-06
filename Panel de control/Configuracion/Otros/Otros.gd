extends Panel

func _ready():
	$autosave.pressed = Tools.padre.config["autosave"]

func _on_cache_pressed():
	Tools.ventana("Confirma...","Estas seguro que quieres borrar la caché?",self,"cache")
	
func cache():
	Tools.delete_dir(Carga.location + "/cache",true)
	Carga._enter_tree()
	#Tools.cargar_escena("res://Panel de control/Main.tscn")


func _on_reset_pressed():
	Tools.ventana("Confirma...","Estas seguro que quieres borrar todos los datos guardados de Twitch MegaBot? Tendrás de reiniciar la aplicación y volver al setup.",self,"reset")

func reset():
	Tools.delete_dir(Carga.location + "/config",true)
	Directory.new().remove(Carga.location + "/users.mega-file")
	TwitchApi.cola = []
	TwitchApi.http.cancel_request()
	get_tree().quit()#get_tree().change_scene("res://Load.tscn")


func autosave(button_pressed):
	Tools.padre.config["autosave"] = button_pressed
