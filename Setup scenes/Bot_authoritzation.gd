extends Control
var nodo
func _enter_tree():
	var temp
	nodo = get_tree().current_scene
	var texto = $ScrollContainer/VBoxContainer/Texto
	var scopes = $"Iniciar sesión twitch"
	if nodo.config["puntos"]:
		temp = true
		scopes.scopes += "channel:manage:redemptions-channel:read:redemptions"
		texto.text += " \n - Acceder y modificar los canjeos (Puntos del bot) \n"
	if nodo.config["Type"]:
		temp = true
		scopes.scopes += ("" if scopes.scopes == "" else "-") + "chat:read-chat:edit-user:edit-user:edit:follows-channel:moderate-moderation:read-whispers:edit-whispers:read"
		
		texto.text += " \n - Prácticamente control total, susurros, moderación y configurar la cuenta en sí (Has seleccionado la cuenta del canal como bot) \n"
	
	if !temp: presionado()
	print(scopes.scopes)
	nodo.config["channel_scopes"] = scopes.scopes

func finalizado(token, expires,refresh_token):
	TwitchApi.info_token(token,"_finalizado",self)
	nodo.config["channel_token"] = token
	nodo.config["channel_refresh_token"] = refresh_token
	if nodo.config["Type"]:
		nodo.config["bot_token"] = token
		nodo.config["bot_refresh_token"] = refresh_token
func _finalizado(data):
	if data["login"] != nodo.config["channel_data"]["login"]:
		Tools.ventana("Inicio de sesiónn incorrecto","Has iniciado sesión con %s, has de hacerlo con %s" % [data["login"],nodo.config["channel_data"]["login"]])
		$"Iniciar sesión twitch".locked = false
		return
	$Siguiente.disabled = false



func presionado():
	get_parent().add_child(preload("res://Setup scenes/Bot_points-setup.tscn").instance())
	queue_free()
