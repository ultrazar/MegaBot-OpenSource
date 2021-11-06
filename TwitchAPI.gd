extends Node
var http : HTTPRequest = HTTPRequest.new()

var websocket =  WebSocketClient.new()
signal reward_redeemed(data)

var response
var token
var nodo
var cola = []
var channel_timer = Timer.new()
var bot_timer
const client_id = "<Your Client id>"
const secret = '<Your API secret>'
var anti_bucle = false #TODO: Erase this parameter xd

#La clase TwitchApi para controlar una cuenta de twitch, adaptada para el uso de MegaBot.
#TODO: Arreglar este desastre que a veces da errores
func _init():
	assert(client_id != "<Your Client id>", "You need to change this parameter!")
	assert(secret != '<Your API secret>', "You need to change this parameter!")
	websocket.verify_ssl = true

func _ready():
	websocket.connect("data_received",self,"data_r")
	websocket.connect("server_disconnected",self,"disconnected")
	websocket.connect("connection_established",self,"conectado")
	websocket.connect("connection_succeeded",self,"conectado")
	websocket.connect("connection_closed",self,"disconnected")
	var t = websocket.connect_to_url("wss://pubsub-edge.twitch.tv")
	if t != OK:
		Tools.error("Web:" + t,"Ha ocurrido un error al intentar conectar el websocket")
		return
	var web_t = Timer.new()
	web_t.connect("timeout",self,"ping",[web_t])
	web_t.autostart = true
	web_t.wait_time = 60
	add_child(web_t)
func conectado(data):
	print("web. connected")
	websocket.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
var waiting = 21
func ping(timer:Timer):
	if(websocket.get_connection_status() != NetworkedMultiplayerPeer.CONNECTION_DISCONNECTED):
		print("PubSub ping")
		websocket.get_peer(1).put_packet(JSON.print({"type":"PING"}).to_utf8())
		waiting = 0
		timer.wait_time = 60 + rand_range(-5,5)
	else:
		print("timer desconectado")
		timer.queue_free()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		pass#ping(Timer.new())

func _process(delta):
	if waiting != 21:
		if waiting < 4:
			waiting += delta
		elif waiting > 21:
			if waiting > 25:
				Tools.error("Twitch PubSub no responde", "Pues eso, que no responde, los canjeos no se detectarán")
				Tools.padre.notif.add_notification("Error PubSub","El servicio de twitch 'PubSub' no responde. De manera que los canjeos, bits y subs no se detectarán",Tools.padre.notif.colors.RED)
				waiting = 21
			else:
				waiting += delta
		else:
			websocket.disconnect_from_host()
			websocket.connect_to_url("wss://pubsub-edge.twitch.tv")
			print("reconnecting...")
			waiting = 22
	anti_bucle = false
	if(websocket.get_connection_status() != NetworkedMultiplayerPeer.CONNECTION_DISCONNECTED):
		websocket.poll()

func disconnected(algo):
	if Tools.padre.filename == "res://Panel de control/Main.tscn":
		Tools.padre.notif.add_notification("ERROR pubsub","Desconectado del PubSub service, los canjeos ya no se detectarán.",Tools.padre.notif.colors.RED)
	else:
		Tools.error("Desconectado del PubSub","Los canjeos ya no se detectarán.")

func pubsub(topics):
	if(websocket.get_connection_status() != NetworkedMultiplayerPeer.CONNECTION_DISCONNECTED):
		var text = JSON.print({"type":"LISTEN","data":{"topics":[topics],"auth_token":Tools.padre.config["channel_token"]}})
		websocket.get_peer(1).put_packet(text.to_utf8())

func data_r():
	var data = websocket.get_peer(1).get_packet().get_string_from_utf8()
	data = JSON.parse(data).result
	
	if data.has("data"):
		data = data["data"]["message"]
		data = JSON.parse(data).result
	match data["type"]:
		"reward-redeemed":
			print("redemmed")
			emit_signal("reward_redeemed",data["data"]["redemption"])
		"PONG":
			print("PubSub Pong " + str(waiting) + " s.")
			waiting = 21
		_:
			print("another " + data["type"])
			if data.has("data"):
				print(data["data"]["message"])

func _enter_tree():
	nodo = Tools.padre
	add_child(http)
	http.connect("request_completed",self,"finalizo")
func _start():
	nodo = Tools.padre
	if !nodo.config["Type"]:
		bot_timer = Timer.new()
		bot_timer.autostart = true
		bot_timer.wait_time = 60
		add_child(bot_timer)
		bot_timer.connect("timeout",self,"bot_refresh")
	channel_timer.autostart = true
	channel_timer.wait_time = 60
	add_child(channel_timer)
	channel_timer.connect("timeout",self,"channel_refresh")

func bot_refresh():
	refresh(false)

func channel_refresh():
	refresh(true)
signal token_refreshed
func refresh(type):
	var url = "https://id.twitch.tv/oauth2/token?grant_type=refresh_token&client_id=" + client_id + "&client_secret=" + secret +  "&refresh_token=" + (nodo.config["channel_refresh_token"] if type else nodo.config["bot_refresh_token"])
	if http.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED or anti_bucle:
		anti_bucle = true
		print("queuing...")
		cola.append(["_refresh",self,[url,[],false,HTTPClient.METHOD_POST,"" ],type])
		return
	response = ["_refresh",self,type]
	http.request(url,[],false,HTTPClient.METHOD_POST)
func _refresh(data,type):
	if data.size() < 4:
		push_error(str(data) + "CHANNEL" if type else "BOT")
		if type:
			channel_timer.wait_time = 999999
		else:
			bot_timer.wait_time = 999999
		return
	if type:
		nodo.config["channel_refresh_token"] = data["refresh_token"]
		nodo.config["channel_token"] = data["access_token"]
		#channel_timer.wait_time = data["expires_in"] - 60

	else:
		nodo.config["bot_refresh_token"] = data["refresh_token"]
		nodo.config["bot_token"] = data["access_token"]
		#bot_timer.wait_time = data["expires_in"] - 60
	emit_signal("token_refreshed")
	

func info_token(_token : String,responses,node):
	if http.get_http_client_status() == HTTPClient.STATUS_REQUESTING or anti_bucle:
		cola.append([responses,node,["https://id.twitch.tv/oauth2/validate",['Authorization: OAuth ' + _token],false,HTTPClient.METHOD_GET,""]])
		return
	anti_bucle = true
	response = [responses,node]
	http.request("https://id.twitch.tv/oauth2/validate",['Authorization: OAuth ' + _token],false,HTTPClient.METHOD_GET)

func finalizo(result, response_code, headers, body):
	if response == [null,null] or body.size() == 0:
		return
	var json = JSON.parse(body.get_string_from_utf8()).result
	if response.size() > 2:  
		if response[2] != null: 
			response[1].call(response[0],json,response[2]) 
		else: 
			response[1].call(response[0],json)
	else: response[1].call(response[0],json)
	if cola.size() > 0:
		if cola[0].size() > 3: response = [cola[0][0],cola[0][1],cola[0][3]]
		else: response = [cola[0][0],cola[0][1]]
		var temp = cola[0][2]
		http.request(temp[0],temp[1],temp[2],temp[3],temp[4])
		cola.remove(0)

func info_usuario(ID,responses,node,login=null,binds=null):
	var url = "https://api.twitch.tv/helix/users?id=" + str(ID) if login == null else "https://api.twitch.tv/helix/users?login=" + str(login)
	if http.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		cola.append([responses,node,[url,acces(false),false,HTTPClient.METHOD_GET,""],binds])
		return
	response = [responses,node,binds]
	http.request(url,acces(false),false,HTTPClient.METHOD_GET)

func canjeos(responses,node):
	if http.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED or anti_bucle:
		cola.append([responses,node,["https://api.twitch.tv/helix/channel_points/custom_rewards?broadcaster_id=" + str(nodo.config["channel_id"]),['Authorization: Bearer ' + nodo.config["channel_token"], 'Client-Id: ' + client_id],false,HTTPClient.METHOD_GET,""]])
		return
	response = [responses,node]
	anti_bucle = true
	http.request("https://api.twitch.tv/helix/channel_points/custom_rewards?broadcaster_id=" + str(nodo.config["channel_id"]),['Authorization: Bearer ' + nodo.config["channel_token"], 'Client-Id: ' + client_id],false,HTTPClient.METHOD_GET)

func crear_canjeo(data,responses,node):
	response = [responses,node]
	var query_string = JSON.print(data)
	var headers = acces(true)
	var result = http.request("https://api.twitch.tv/helix/channel_points/custom_rewards?broadcaster_id=" + str(nodo.config["channel_id"]),headers,false,HTTPClient.METHOD_POST, query_string)
	if result != OK:
		push_error("Something went  wrong trying to make a reward error: " + str(result) )

func redemptions(responses,node,reward_id="",type="UNFULFILLED"):
	var command = ["https://api.twitch.tv/helix/channel_points/custom_rewards/redemptions?broadcaster_id=" + str(nodo.config["channel_id"] + "&reward_id=" + reward_id + "&status=" + type),acces(),false,HTTPClient.METHOD_GET,""]
	command(command,responses,node)

func update_redemption(reward_id,redemption_id,responses,node,status="FULFILLED"):
	var query_string = JSON.print({"status": status})
	var command = ["https://api.twitch.tv/helix/channel_points/custom_rewards/redemptions?broadcaster_id=%s&reward_id=%s&id=%s" % [str(nodo.config["channel_id"]),reward_id,redemption_id],acces(true),false,HTTPClient.METHOD_PATCH,query_string]
	print(str(command))
	command(command,responses,node)

func command(request,responses,node):
	#print(str(http.get_http_client_status()))
	if http.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		anti_bucle = true
		cola.append([responses,node,request])
		return
	response = [responses,node]
	http.request(request[0],request[1],request[2],request[3],request[4])

func acces(get = false):
	var result = ['Authorization: Bearer ' + Tools.padre.config["channel_token"], 'Client-Id: ' + client_id]
	if get: result.append('Content-Type: application/json')
	return result

func eliminar_canjeo(ID, responses = null, node = null):
	response = [responses,node]
	var headers = acces(false)
	var result = http.request("https://api.twitch.tv/helix/channel_points/custom_rewards?broadcaster_id=" + str(nodo.config["channel_id"]) + "&id=" + str(ID),headers,false,HTTPClient.METHOD_DELETE)
	if result != OK:
		push_error("Something went  wrong trying to delete a reward error: " + str(result) )

#Es un desastre, ya lo se :v Le falta un monton de optimización. La he ido completando a la vez que aprendia sin seguir ningún orden
