extends WindowDialog

var bots
func cargar(filtro=$busqueda.text):
	Tools.delete_childs($Panel/scroll/vbox)
	var users = Tools.padre.get_node("bot").users
	bots = false #$temporals.pressed
	if filtro != "":
		for a in users:
			if ( (users[a]["status"] != Tools.bot.user_status.BOT) if bots else (users[a]["status"] == Tools.bot.user_status.BOT) ) or a.find(filtro) == -1:
				continue
			var nodo = preload("res://Panel de control/Usuarios/usuario.tscn").instance()
			nodo.get_node("nombre").text = a
			$Panel/scroll/vbox.add_child(nodo)
			if bots: nodo.bot()
	else:
		for a in users:
			if ( (users[a]["status"] != Tools.bot.user_status.BOT) if bots else (users[a]["status"] == Tools.bot.user_status.BOT) ):
				continue
			var nodo = preload("res://Panel de control/Usuarios/usuario.tscn").instance()
			nodo.get_node("nombre").text = a
			$Panel/scroll/vbox.add_child(nodo)
			if bots: nodo.bot()
"""
func desbot(nodo):
	actual = nodo.get_node("nombre").text
	Tools.ventana("Des-bot","Quieres que MegaBot ya no cuente como bot a %s?" % actual,self,"_desbot")
func _desbot():
	if Tools.padre.cloud_mgr != null:
		var mgr : Firestore_mgr = Tools.padre.cloud_mgr
		var bots : Array = yield(mgr.open("antibot"),"completed")
		
		if !bots.has(actual):
			Tools.bot.bots = bots
			Tools.ventana(":v","Pues al parecer le han quitado el bot hace poco.")
			return
		bots.erase(actual)
		Tools.bot.bots = bots
		Tools.bot.users[actual]["status"] = Tools.bot.user_status.OK
		yield(mgr.update("antibot",bots),"completed")
		Tools.ventana("Listo","Ya está. Grácias por contribuir a que MegaBot sea mejor. (Otros streamers/mods lo pueden deshacer)")
		
		cargar($busqueda.text) #Vuelve a cargar los usuarios
		return
	
	Tools.ventana("F","F en el chat, no hemos podido. Vuelva a intentarlo más tarde...")
"""
func _on_busqueda_text_changed(new_text):
	cargar(new_text)


func showing():
	cargar()

var actual
func info(nodo):
	#$user/report.visible = not bots
	$user.popup_centered()
	var nombre = nodo.get_node("nombre").text
	actual = nombre
	var bot = Tools.padre.get_node("bot")
	Carga._load(bot.users[nombre]["user_data"]["profile_image_url"],$user/logo)
	$user.window_title = nombre
	$user/Info.text =  "Primer mensaje: %s \nUltima conexión: %s \nPuntos: %s \nStreamer: %s" % [
		Tools.string_from_unix(bot.users[nombre]["first_date"],2),
		Tools.string_from_unix(bot.users[nombre]["date"],2),
		str(bot.users[nombre]["puntos"]),
		bot.users[nombre]["user_data"]["broadcaster_type"] if bot.users[nombre]["user_data"]["broadcaster_type"] != "" else "No"  ]
	

func eliminar(nodo):
	Tools.padre.get_node("bot").users.erase(nodo.get_node("nombre").text)
	cargar($busqueda.text)
	

func _on_aadir_pressed():
	var bot = Tools.padre.get_node("bot")
	bot.users[actual]["puntos"] += $user/puntos.value
	$user/puntos.value = 0
	var nombre = actual
	$user/Info.text =  "Primer mensaje: %s \nUltima conexión: %s \nPuntos: %s \nStreamer: %s" % [
		Tools.string_from_unix(bot.users[nombre]["first_date"],2),
		Tools.string_from_unix(bot.users[nombre]["date"],2),
		str(bot.users[nombre]["puntos"]),
		bot.users[nombre]["user_data"]["broadcaster_type"] if bot.users[nombre]["user_data"]["broadcaster_type"] != "" else "No"  ]


func _on_report_pressed():
	Tools.ventana("Reportar:","Quiere reportar el usuario como bot? MegaBot lo guardará en la nube y ya no lo contará como un usuario en el chat. (se puede deshacer)",self,"report")
"""
func report():
	if Tools.padre.cloud_mgr != null:
		var mgr : Firestore_mgr = Tools.padre.cloud_mgr
		var bots : Array = yield(mgr.open("antibot"),"completed")
		
		if bots.has(actual):
			Tools.bot.bots = bots
			Tools.ventana(":v","Pues al parecer lo acaban de reportar hace poco.")
			return
		bots.append(actual)
		Tools.bot.bots = bots
		Tools.bot.users[actual]["status"] = Tools.bot.user_status.BOT
		yield(mgr.update("antibot",bots),"completed")
		Tools.ventana("Reportado","Ya está. Grácias por contribuir a que MegaBot sea mejor. (Otros streamers/mods lo pueden deshacer)")
		
		cargar($busqueda.text) #Vuelve a cargar los usuarios
		return
	
	Tools.ventana("F","F en el chat, no hemos podido reportarlo. Vuelva a intentarlo más tarde...")
"""
