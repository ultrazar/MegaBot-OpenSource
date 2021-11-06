extends Node
var config
var mode = true

func _enter_tree():
	Tools.padre = self
	get_tree().get_root().transparent_bg = true
func _ready():
	print("Buscando Setup.mega-file")
	var dir = Directory.new()
	if !dir.dir_exists(Tools.pos + "/config") or !dir.file_exists(Tools.pos + "/config/setup.mega-file"):
		Tools.cargar_escena("res://Setup/Setup.tscn",self,"changing_scene")
		return
	config = Tools.cargar("/config/setup.mega-file")
	if !config["setuped"]:
		Tools.cargar_escena("res://Setup/Setup.tscn",self,"changing_scene")
		return
	#Guardado en la nube deshabilitado para la versión de codigo abierto, la clase firestore_mgr esta eliminada por razones de seguridad
	"""" 
	if config["autosave"] and mode: #Procede a hacer un backup en la nube
		var mgr = Firestore_mgr.new(self) 
		yield(mgr,"autorizado")
		var path = "MegaBot users/" + config["channel_data"]["login"]
		var s = yield(mgr.open(path + "/backup"),"completed")
		if typeof(s) == TYPE_INT: #Comprueba si ya existe el archivo "backup" para saber si hay que crearlo o actualizarlo
			yield(mgr.create(path,"backup",OS.get_unix_time()),"completed")
			yield(mgr.create(path + "/backup/","config",config),"completed")
			yield(mgr.create(path + "/backup/","users",Tools.cargar("/users.mega-file")),"completed")
			yield(mgr.create(path + "/backup/","commands",Tools.cargar("/Config/commands.mega-file")),"completed")
			yield(mgr.create(path + "/backup/","e_commands",Tools.cargar("/Config/e_commands.mega-file")),"completed")
		else:
			yield(mgr.update(path + "/backup",OS.get_unix_time()),"completed")
			yield(mgr.update(path + "/backup/config",config),"completed")
			yield(mgr.update(path + "/backup/users",Tools.cargar("/users.mega-file")),"completed")
			yield(mgr.update(path + "/backup/commands",Tools.cargar("/Config/commands.mega-file")),"completed")
			yield(mgr.update(path + "/backup/e_commands",Tools.cargar("/Config/e_commands.mega-file")),"completed")
	"""
	
	print("Refrescando Tokens...")
	TwitchApi.nodo = self
	TwitchApi.bot_refresh()
	yield(TwitchApi,"token_refreshed")
	TwitchApi.channel_refresh()
	yield(TwitchApi,"token_refreshed")
	print("Validando Tokens...")
	TwitchApi.info_token(config["channel_token"],"validar",self)

var temp = [false,false]
func validar(data):
	if data.size() < 4:
		temp[0] = true
	
	if config["Type"]:
		finish()
	else:
		TwitchApi.info_token(config["bot_token"],"_validar",self)
	
func _validar(data):
	if data.size() < 4:
		temp[1] = true
	
	finish()


func finish():
	config["channel_token_state"] = "WORKS" if !temp[0] else "ERROR"
	config["bot_token_state"] = "WORKS" if !temp[1] else "ERROR"
	Tools.guardar("/config/setup.mega-file",config)
	
	if temp[0] or temp[1]:
		print("Necesita iniciar sesion")
		Tools.cargar_escena("res://Iniciar_sesion.tscn",self,"changing_scene")
	else:
		print("Todo correcto:")
		Tools.cargar_escena("res://Panel de control/Main.tscn",self,"changing_scene")

func changing_scene():
	Tools.window_mode(Tools.window_modes.RUNTIME)
	
