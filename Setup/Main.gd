extends Node2D
var datos
var pos
#La configuración predetermindada: !!!
var config = { "autosave":true,"setuped":false,"Type": true, "alertas" : {"resolucion": [300,300]}} setget guardar
#var mgr

func _enter_tree():
	pos = Carga.location
	#mgr = Firestore_mgr.new(self)
	#yield(mgr,"autorizado")

func _ready():
	OS.min_window_size = Vector2(500,500)
	OS.window_borderless = false
	OS.set_window_always_on_top(false)
	var file = Directory.new()
	file.open(pos)
	if file.dir_exists("Config"):
		file.open("Config")
		if file.file_exists("setup.mega-file"):
			var f = abrir()
			if f.has("channel_data"):
				print("Accediendo...")
				#print(str(f))
				config = f
				acabar()
				return
				TwitchApi.info_token(config["channel_token"],"info_token",self)
				if !config["Type"]:
					TwitchApi.info_token(config["bot_token"],"bot_info_token",self)
				return
		Tools.delete_dir(pos + "/Config",false)
	else:
		var b = file.make_dir("Config")
		if b != OK:
			breakpoint
	Tools.guardar("/Config/setup.mega-file",{})
	guardar(config)
	

func info_token(data):
	print("channel: " + str(data))
	if data.size() < 4:
		return
	__comenzar({"data" : [config["channel_data"]]})

func bot_info_token(data):
	print("bot: " + str(data))
	if data.size() < 4:
		return

func guardar(data):
	var file = File.new()
	var c = file.open_encrypted_with_pass(pos + "/Config/setup.mega-file",file.WRITE,"Megazar21 es el mejor")
	if c != OK:
		breakpoint
	file.store_var(data)
	file.close()

func abrir():
	var file = File.new()
	var c = file.open_encrypted_with_pass(pos + "/Config/setup.mega-file",file.READ,"Megazar21 es el mejor")
	if c != OK:
		breakpoint
	var a = file.get_var()
	file.close()
	return a

func comenzar(token, expires,refresh_token):
	config["channel_token"] = token
	config["channel_refresh_token"] = refresh_token
	TwitchApi.info_token(token,"_comenzar",self)
func _comenzar(info):
	$Label.text = info["login"]
	#Comprueba si hay copias de seguridad en la nube en este usuario...
	""""
	print("Buscando copias de seguridad en la nube")
	login = info["login"]
	var path = "MegaBot users/" + login
	var s = yield(mgr.open(path + "/backup"),"completed")
	if typeof(s) != TYPE_INT: #Si existe...
		s = int(s)
		var gmt = OS.get_time_zone_info()["bias"] / 60
		var date = OS.get_datetime_from_unix_time(s + (gmt*3600))
		var str_date = Tools.string_from_unix(s,gmt)
		print("Copia de seguridad encontrada del: " + str_date)
		Tools.ventana("Se ha encontrado una copia de seguridad en la nube","Quiere saltarse el setup utilizando la configuración del %s?" % str_date,self,"restaurando" )
	else:
		print("No se han encontrado copias de seguridad")
	"""
	TwitchApi.info_usuario(info["user_id"],"__comenzar",self)

var login : String
"""
func restaurando():
	get_tree().paused = true
	var s = yield(mgr.open("MegaBot users/%s/backup" % login,true),"completed")
	Tools.guardar("/config/setup.mega-file",s["config"]);
	Tools.guardar("/users.mega-file",s["users"]);
	Tools.guardar("/Config/commands.mega-file",s["commands"]);
	Tools.guardar("/Config/e_commands.mega-file",s["e_commands"])
	Tools.cargar_escena("res://Load.tscn",self,"_rest")
	get_tree().paused = false
"""
func _rest():
	Tools.padre.mode = false #Esto es para que se salte el autosave
	Tools.window_mode(Tools.window_modes.LOAD)

func __comenzar(info):
	$"Center/Iniciar sesión twitch".queue_free()
	$Label.text = info["data"][0]["display_name"]
	datos = info["data"][0]
	config["channel_id"] = info["data"][0]["id"]
	config["channel_data"] = info["data"][0]
	Carga._load(datos["profile_image_url"],$TextureRect)
	$Center.add_child(preload("res://Setup scenes/Bienvenida.tscn").instance())

func acabar():
	if config["Type"]:
		config["bot_data"] = config["channel_data"]
	var color = Gift.Colors.keys()
	color.sort()
	config["setuped"] = true
	config["chat_color"] = color.pop_back()
	config["users"] = {"expires": 10, "notif":true}
	guardar(config)
	Tools.guardar("/users.mega-file",{})
	Tools.guardar("/Config/e_commands.mega-file",[])
	Tools.guardar("/Config/commands.mega-file",[["test","[usuario], funciona!",[false,0],[false],["prueba"] ]])
	Tools.cargar_escena("res://Panel de control/Main.tscn")
