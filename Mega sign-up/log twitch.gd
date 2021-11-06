extends Control
signal finalizado(token,timeout,refresh_token)
export var scopes : String
var state : String
var host : Tools.localhost
var loading = false
var locked = false

var response_html = Tools.cargar_externo("res://Mega sign-up/response.html")
func presionado():
	if loading:
		loading = false
		host = null
		$Cargar.hide()
		$Boton/Label.show()
		return
	$Cargar.show()
	$Boton/Label.hide()
	loading = true
	scopes = scopes.replace("-"," ")
	var _scopes = scopes.percent_encode()
	host = Tools.localhost.new(17563,self,response_html)
	host.connect("posted",self,"posted")
	state = Tools.token_generate(30)
	OS.shell_open(Tools.build_url("https://id.twitch.tv/oauth2/authorize",{"client_id":TwitchApi.client_id,"redirect_uri":"http://localhost:17563","response_type":"code","scope":_scopes,"state":state}))

func posted(data:Dictionary):
	host.stop()
	host = null
	if data["state"] != state:
		Tools.error("","Error al intentar verificar el 'state', por favor, intentelo de nuevo")
		return
	if data.has("error"):
		Tools.ventana("Porque denegas?", "Has de dar a autorizar para continuar")
		$Cargar.show()
		$Boton/Label.hide()
		locked = false
		return
	Tools.rapid_request("https://id.twitch.tv/oauth2/token",HTTPClient.METHOD_POST,{"client_id":TwitchApi.client_id,"client_secret":TwitchApi.secret,"code":data["code"],"grant_type":"authorization_code","redirect_uri":"http://localhost:17563"},self,"finalizado",['Client-Id: rh5rqqu9s1vobp4k5etmeyijl1n8vg','Content-Type: application/json'])
	

func finalizado(data):
	loading = false
	data = data[0]
	if data.has("message"):
		Tools.error("","Error al conseguir el token por el 'code', por favor, intentelo de nuevo")
		return
	$Cargar.hide()
	$Boton/Label.show()
	$Boton/Label.text = "Finalizado"
	emit_signal("finalizado",data["access_token"],data["expires_in"],data["refresh_token"])
	



