extends Panel
var nodo
var listado
var comando = preload("res://Panel de control/Configuracion/Comandos/Command.tscn")
var actual_edit : Node
var data
var bot

func guardar(_data):
	Tools.guardar("/Config/commands.mega-file",_data)
	return
	var file = File.new()
	var c = file.open_encrypted_with_pass(nodo.pos + "/Config/commands.mega-file",file.WRITE,"Megazar21 es el mejor")
	if c != OK:
		Tools.error(str(c),"No se ha podido abrir el archivo de guardado de los comandos" if c == ERR_FILE_NOT_FOUND else "Ha ocurrido un error")
		return
	file.store_var(_data)
	file.close()

func _ready():
	nodo = Tools.padre
	bot = nodo.get_node("bot")
	listado = $PanelContainer/ScrollContainer/vbox
	reload()
	if !nodo.config["puntos"]:
		$edit/v/hbox/Puntos.free()
	
func reload():
	data = Tools.cargar("/Config/commands.mega-file")
	if data == null:
		push_error("Error loading commands")
		return
	Tools.delete_childs(listado)
	for a in data:
		var nuevo = comando.instance()
		listado.add_child(nuevo)
		nuevo.get_node("Label").text = a[0] + "   -   " + a[1]
		nuevo.comando = a[0]
		nuevo.respuesta = a[1]
		nuevo.data = a
		bot.purge_command(a[0])
		bot.add_command(a[0],bot,"personalizated_command")
		bot.add_aliases(a[0],a[4])

func editar(boton):
	$edit.window_title = "Editar comando"
	$edit.popup_centered()
	$edit/v/titulo.text = boton.comando
	$edit/v/respuesta.text = boton.respuesta
	$edit/v/hbox/Puntos.pressed = boton.data[2][0]
	$edit/v/coste.value = boton.data[2][1]
	$edit/v/hbox/Alertas.pressed = boton.data[3][0]
	if boton.data[2][0]:
		$edit/v/Imagen.pressed = true if boton.data[3][1] != "" else false
		$edit/v/sonido.pressed = true if boton.data[3][2] != "" else false
		$edit/v/_imagen/Label.text = boton.data[3][1]
		$edit/v/_sonido/Label.text = boton.data[3][2]
	$edit/v/alias._update(boton.data[4])
	_on_Puntos_pressed()
	_on_Alertas_pressed()
	actual_edit = boton

func eliminar(boton):
	var pos = Tools.array_in_arrays(data,0)
	pos = pos.find(boton.comando)
	data.remove(pos)
	bot.purge_command(boton.comando)
	guardar(data)
	reload()

func _on_Comandos_visibility_changed():
	reload()

func _on_guardar_pressed():
	var result = [$edit/v/titulo.text,
	$edit/v/respuesta.text,
	[$edit/v/hbox/Puntos.pressed,$edit/v/coste.value],
	[$edit/v/hbox/Alertas.pressed,$edit/v/_imagen/Label.text if $edit/v/hbox/Alertas.pressed and $edit/v/Imagen.pressed else "",$edit/v/_sonido/Label.text if $edit/v/hbox/Alertas.pressed and $edit/v/sonido.pressed else ""],
	$edit/v/alias.array]
	if actual_edit != null:
		var pos = Tools.array_in_arrays(data,0)
		pos = pos.find(actual_edit.comando)
		if pos == -1:
			breakpoint#push_error("")
		else:
			bot.remove_command(data[pos][0])
			data[pos] = result
	else:
		data.append(result)
	guardar(data)
	reload()
	$edit.hide()

func _on_aadir_pressed():
	$edit.window_title = "Añadir comando"
	actual_edit = null
	$edit/v/titulo.placeholder_text = "Comando ( ej: saludar )"
	$edit/v/respuesta.text = 'Respuesta... (ej: "Hola [usuario]")'
	$edit/v/hbox/Puntos.pressed = false
	$edit/v/hbox/Alertas.pressed = false
	$edit/v/alias.array = ["hola"]
	$edit/v/alias._update()
	_on_Puntos_pressed()
	_on_Alertas_pressed()
	$edit.popup_centered()

func _on_Puntos_pressed():
	$edit/v/coste.visible = $edit/v/hbox/Puntos.pressed

func _on_Alertas_pressed():
	var v = $edit/v/hbox/Alertas.pressed
	$edit/v/Imagen.visible = v
	$edit/v/_imagen.visible = $edit/v/Imagen.pressed and v
	$edit/v/sonido.visible = v
	$edit/v/_sonido.visible = $edit/v/sonido.pressed and v

func _on_info_pressed():
	$variables.popup_centered()

func _on_vvbox_item_rect_changed():
	$edit/v.rect_size = Vector2(0,0)
	$edit.rect_min_size = $edit/v.rect_size + Vector2(20,20)
	$edit.rect_size = $edit.rect_min_size


func _on_selec_pressed():
	var path = Tools.file_popup("Selecciona imagen",["*.png","*.jpg","*.gif"])
	path = yield(path,"completed")
	
	$edit/v/_imagen/Label.text = path

func _on_selec_s_pressed():
	var path = Tools.file_popup("Selecciona un sonido",["*.wav","*.mp3"])
	path = yield(path,"completed")
	
	$edit/v/_sonido/Label.text = path


func _on_Imagen_toggled(button_pressed):
	$edit/v/_imagen.visible = button_pressed

func _on_sonido_toggled(button_pressed):
	$edit/v/_sonido.visible = button_pressed




