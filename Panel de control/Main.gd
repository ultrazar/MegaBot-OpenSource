extends Control

var pos
var config = {"alertas" : {"resolucion": Vector2(300,300)}} setget guardar
var alertas #setget guardar
var notif : Control
var cloud_mgr

func guardar(data):
	var file = File.new()
	var c = file.open_encrypted_with_pass(pos + "/Config/setup.mega-file",file.WRITE,"Megazar21 es el mejor")
	if c != OK:
		breakpoint
	file.store_var(data)
	file.close()

func _enter_tree():
	Tools.window_mode(Tools.window_modes.RUNTIME)
	
	pos = Carga.location
	var file = File.new()
	var c = file.open_encrypted_with_pass(pos + "/Config/setup.mega-file",file.READ,"Megazar21 es el mejor")
	if c != OK:
		breakpoint
	config =  file.get_var()
	file.close()
	
	if config["puntos"]:
		var puntos = load("res://Panel de control/Points/points.tscn").instance()
		get_node("bot").add_child(puntos)
	
	# La clase Firestore_mgr para lista de usuarios baneados en la nube. Esta eliminada para la versión de codigo abierto.
	"""
	var temp = Firestore_mgr.new(self) #La variable cloud_mgr sera el recurso cuando este disponible
	yield(temp,"autorizado")
	cloud_mgr = temp
	
	$bot.bots = yield(cloud_mgr.open("antibot"),"completed")
	$bot.update_bots()
	"""

func _ready():
	notif = $Notificaciones
	TwitchApi._start()
	$bot._start()
	Tools._ready()
	alertas = $CanvasLayer/titulo/alertas/viewport/Control


func _on_config_pressed():
	$config.popup_centered()

func _on_users_pressed():
	$users.popup_centered()

func _on_switch_pressed():
	if $bot.estado:
		#apagar
		$bot.disconnect_from_twitch()
		$Estado.bbcode_text = "Estado: [b][color=#FF6161]apagado[/color][/b]"
		$Estado/switch.text = "encender"
		$Estado/switch.set("custom_colors/font_color",Color("6ecf37")) 
		$bot.estado = false
	else:
		$bot._start()



