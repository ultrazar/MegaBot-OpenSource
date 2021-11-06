extends Control
var nodo
var canjeo = preload("res://Canjeos control/Canjeo.tscn")
signal selected(button_data)
var eliminando = false
var id_temp

func _ready():
	var a = Timer.new()
	a.autostart = true
	a.one_shot = true
	a.wait_time = 1
	add_child(a)
	a.connect("timeout",self,"temp")
func temp(nothing = null):
	if nothing != null:
		if nothing.size() == 3:
			push_error(str(nothing))
			return
	Tools.delete_childs($ScrollContainer/GridContainer)
	nodo = Tools.padre
	TwitchApi.canjeos("_canjeos",self)
	$Loading.show()

func _canjeos(data):
	if data.size() > 1:
		push_error(str(data))
		return
	$Loading.hide()
	var _data = data["data"]
	for a in _data:
		var b = canjeo.instance()
		$ScrollContainer/GridContainer.add_child(b)
		var url = a["default_image"]["url_2x"]
		if a["image"] != null:
			url = a["image"]["url_2x"]
		b.init(url,a["background_color"], a["title"],a)

func pressed(boton):
	if eliminando:
		$eliminar.window_title = "¿Seguro que quieres eliminar:  \"" + boton.data["title"] + "\"?"
		$eliminar.popup_centered()
		id_temp = boton.data["id"]
		return
	emit_signal("selected",boton.data)


func _on_Refrescar_pressed():
	temp()


func Anadir():
	$anadir.popup_centered()


func _on_Button_pressed():
	TwitchApi.crear_canjeo({"title": $anadir/titulo.text, "prompt": $anadir/descripcion.text, "cost": str(int($anadir/coste.text)),"background_color": "#" + $anadir/color/Color.color.to_html(false),"is_user_input_required": $anadir/Texto.pressed},"temp",self)


func _on_eliminar_pressed():
	eliminando = !eliminando


func _on_eliminar_confirmed():
	TwitchApi.eliminar_canjeo(id_temp,"temp",self)
