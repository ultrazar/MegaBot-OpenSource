extends Gift
var nodo
var p_commands
var users = {}
const users_position = "/users.mega-file"
var estado = false
var bots = []
func update_bots():
	for a in users:
		if bots.has(a):
			users[a]["status"] = user_status.BOT
		elif users[a]["status"] == user_status.BOT:
			users[a]["status"] = user_status.OK

enum user_status { OK, BOT}

func guardar(data=users):
	Tools.guardar(users_position,data)

func _enter_tree():
	users = Tools.cargar(users_position)
	Tools.bot = self

func _start():
	p_commands = $"../config/TabContainer/Comandos presonalizados"
	nodo = Tools.padre
	
	#Eliminar los usuarios inactivos:
	var momento = OS.get_unix_time()
	var maximo = (nodo.config["users"]["expires"] * 86400)
	var deleted = []
	for a in users:
		if (momento - users[a]["date"]) > maximo:
			print("eliminando " + a)
			deleted.append(a)
			users.erase(a)
	if deleted.size() > 0:
		Tools.ventana("Usuarios eliminados","Se han eliminado %s usuarios de la lista por demasiada inactividad, puede configurar el tiempo máximo en configuracion/usuarios" % deleted.size())
	
	connect_to_twitch()
	yield(self, "twitch_connected")
	print(nodo.config["bot_data"])
	authenticate_oauth(nodo.config["bot_data"]["login"], nodo.config["bot_token"])
	if(yield(self, "login_attempt") == false):
		print("Invalid username or token.")
		estado = "ERROR"
		get_parent().get_node("Estado").bbcode_text = "Estado: [b][color=#%s]ERROR[/color][/b]" % Color.red.to_html()
		get_parent().get_node("Estado/switch").hide()
		Tools.error("","Error al intentar autentificar el bot en twitch, reinicie el programa e intentelo de nuevo")
		return
	join_channel(nodo.config["channel_data"]["login"])
	
	color = nodo.config["chat_color"]
	_color(color)
	
	add_command("eres-megabot?", self, "command_test")
	
	estado = true
	get_parent().get_node("Estado").bbcode_text = "Estado: [b][color=#%s]encendido[/color][/b]" % Color.green.to_html()
	get_parent().get_node("Estado/switch").text = "apagar"
	get_parent().get_node("Estado/switch").set("custom_colors/font_color",Color("FF6161")) 

func command_test(cmd_info : CommandInfo) -> void:
	chat("Si, este bot funciona con MegaBot! Por megazar21 PogChamp ")

var messages = {}
var delete_message = 0
func delete_message(cmd_info : CommandInfo):
	var login = cmd_info.sender_data.tags["display-name"].to_lower()
	
	if !messages.has(login):
		return
	
	if delete_message > 0:#Procede a comprobar y quitar los puntos
		if !users.has(login): 
			chat("No tienes suficientes puntos")
			print("no registrado")
			return
		if users[login]["puntos"] < delete_message:
			chat("No tienes suficientes puntos")
			return
		users[login]["puntos"] -= delete_message
	
	chat("/delete " + messages[login])

func personalizated_command(cmd_info : CommandInfo):
	var array = Tools.array_in_arrays(p_commands.data,0)
	var pos = array.find(cmd_info.command)
	if pos == -1:
		var dpos = get_original_command(cmd_info.command)
		pos = array.find(dpos)
		if pos == -1:
			remove_command(cmd_info.command)
			return
			#breakpoint
	
	var nombre : String = cmd_info.sender_data.tags["display-name"]
	var login : String = nombre.to_lower()
	var comando = p_commands.data[pos]
	var user_pos = users.has(login)
	if comando[2][0]:
		if !user_pos:
			chat("No tienes suficientes puntos")
			print("no registrado")
			return
		var puntos = users[login]["puntos"]
		if puntos < comando[2][1]:
			chat("No tienes suficientes puntos")
			return
		users[login]["puntos"] -= comando[2][1]
		print(users[login]["puntos"])
	
	if comando[3][0]:
		if comando[3][1] != "":
			var extension = comando[3][1].right(comando[3][1].find_last(".") + 1)
			var texture
			print(extension)
			if extension == "gif":
				var g = ImageFrames.new()
				var s = g.load(comando[3][1])
				if s != OK:
					Tools.error(str(s),"Error al cargar: " + comando[3][1])
					return
				texture = Tools.ImageFrames_to_animatedtexture(g)
			else:
				var i = Image.new()
				var e = i.load(comando[3][1])
				if e != OK:
					Tools.error(str(e),"Error al cargar: " + comando[3][1])
				texture = ImageTexture.new()
				texture.create_from_image(i)
			
			Tools.padre.alertas.get_node("gif").texture = texture
			Tools.padre.alertas.alerta_gif()
		if comando[3][2] != "":
			var extension = comando[3][2].right(comando[3][2].find_last(".") + 1)
			var sound
			sound = Tools.GDScriptAudioImport.new()
			sound = sound.loadfile(comando[3][2])
			sound.set("loop_mode",AudioStreamSample.LOOP_DISABLED)
			sound.set("loop",false)
			sound.set("loop_end",10)
			Tools.sound(sound)
	
	var respuesta = comando[1]
	respuesta = respuesta.replace("[usuario]",nombre)
	respuesta = respuesta.replace("[puntos]",users[login]["puntos"] if user_pos else "0")
	chat(respuesta)


func _on_bot_user_joined(user,add=[0]):
	if user == nodo.config["bot_data"]["login"] or bots.has(user):
		return
	if !users.has(user):
		TwitchApi.info_usuario(null,"nuevo_usuario",self,user,[add[0]])
		return
	
	users[user]["date"] = OS.get_unix_time()
	guardar()

func users_ids():
	var final = []
	for a in users:
		final.append(users[a]["id"])
	return final

func nuevo_usuario(_data,cust_p=[0]):
	var data = _data["data"][0] if _data.has("data") else _data
	var c = users_ids().find(data["id"])
	users[data["login"]] = {"user_data": data}
	if c != -1:
		var antigua = users.keys()[c]
		var antigua_data = users[antigua]
		users[data["login"]] = users[antigua]
		users[data["login"]]["user_data"] = data
		users.erase(antigua)
		usuario_cambio_nombre(data["login"])
		Tools.padre.notif.add_notification("Cambio de nombre","Un usuario ya registrado, %s, se ha cambiado de nombre a %s. Hemos actualizado su registro." % [antigua_data["display_name"],data["display_name"]],Tools.padre.notif.colors.YELLOW)
	else:
		if Tools.padre.config["users"]["notif"]:
			Tools.padre.notif.add_notification("Nuevo usuario","Se acaba de registrar %s, %s" % [data["display_name"],("no es streamer." if data["broadcaster_type"] == "" else ("es " + data["broadcaster_type"]))],Tools.padre.notif.colors.NORMAL,data["profile_image_url"])
	
	users[data["login"]]["id"] = data["id"]
	users[data["login"]]["date"] = OS.get_unix_time()
	users[data["login"]]["first_date"] = OS.get_unix_time()
	users[data["login"]]["puntos"] = cust_p[0]
	users[data["login"]]["status"] = user_status.OK

func usuario_cambio_nombre(usuario):
	print("cambio de nombre")
	pass

func _on_bot_chat_message(sender_data, message):
	var login = sender_data.tags["display-name"].to_lower()
	if bots.has(login):
		return
	
	messages[login] = sender_data.tags["id"]
	_on_bot_user_joined(login)


func _on_guardado_timeout():
	guardar()
