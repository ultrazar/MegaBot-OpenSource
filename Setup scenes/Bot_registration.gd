extends Control
var nodo
func _ready():
	$"what?".get_ok().text = "Volver a registrar"
	$"what?".add_cancel("He cambiado de decisión")
	nodo = Tools.padre
var temp
func finalizado(token, _expires,refresh_token):
	temp = [token,refresh_token]
	TwitchApi.info_token(token,"_finalizado",self)
	nodo.config["bot_token"] = token
	nodo.config["bot_refresh_token"] = refresh_token
func _finalizado(data):
	if data["user_id"] == nodo.config["channel_id"]:
		$"what?".popup_centered()
		nodo.config["bot_data"] = nodo.config["channel_data"]
		$Siguiente.disabled = false
	else:
		TwitchApi.info_usuario(data["user_id"],"__finalizado",self)
func __finalizado(data):
	nodo.config["bot_data"] = data["data"][0]
	$Siguiente.disabled = false

func presionado():
	
	get_parent().add_child(preload("res://Setup scenes/Bot_functions.tscn").instance())
	queue_free()


func _on_what_confirmed():
	$"Iniciar sesión twitch".locked = false
	$Siguiente.disabled = true
