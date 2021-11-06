extends Control
var config : Dictionary

func _enter_tree():
	config = Tools.cargar("/config/setup.mega-file")
	

var pending = 2
func _ready():
	$"canal/Iniciar sesión twitch2".scopes = config["channel_scopes"]
	if config["channel_token_state"] == "WORKS":
		$canal.free()
		$"bot/Iniciar sesión twitch/Boton".disabled = false
		pending -= 1
	
	if config["bot_token_state"] == "WORKS":
		$bot.hide()
		pending -= 1
	
	$Titulo.text = "!Bienvenido %s!" % config["channel_data"]["display_name"]


func bot_finished(token, expires,refresh_token):
	config["bot_token"] = token
	config["bot_refresh_token"] = refresh_token
	$"bot/Iniciar sesión twitch/Boton".disabled = true
	TwitchApi.info_token(token,"_bot",self)
func _bot(data):
	if data["login"] != config["bot_data"]["login"]:
		print("false login")
		Tools.ventana("Has iniciado sesion como: " + data["login"],"Tienes de iniciar sesion con el bot, con " + config["bot_data"]["login"])
		$"bot/Iniciar sesión twitch/Boton".disabled = false
		$"bot/Iniciar sesión twitch".locked = false
		return
	b()

func b():
	pending -= 1
	Tools.guardar("/config/setup.mega-file",config)
	if pending == 0:
		Tools.cargar_escena("res://Panel de control/Main.tscn")

func channel_finished(token, expires,refresh_token):
	
	config["channel_token"] = token
	config["channel_refresh_token"] = refresh_token
	$"canal/Iniciar sesión twitch2/Boton".disabled = true
	TwitchApi.info_token(token,"_channel",self)
func _channel(data):
	if data["login"] != config["channel_data"]["login"]:
		print("false login")
		Tools.ventana("Has iniciado sesion como: " + data["login"],"Tienes de iniciar sesion con la cuenta del canal, con " + config["channel_data"]["login"])
		$"bot/Iniciar sesión twitch/Boton".disabled = true
		$"canal/Iniciar sesión twitch2/Boton".disabled = false
		$"canal/Iniciar sesión twitch2".locked = false
		return
	$"bot/Iniciar sesión twitch/Boton".disabled = false
	
	
	
	b()





func _on_saltar_pressed():
	Tools.ventana("Estás seguro?","Si saltas el inicio de sesión necesário, el bot no funciónara, solo podrás ver tus usuarios y modificar comandos/configuración.",self,"saltar")

func saltar():
	Tools.cargar_escena("res://Panel de control/Main.tscn")


