extends Panel
var data = []
const sctructure = [ #[<name>,<bot method>, <sample_name>]
	#del:
	["Eliminar último mensaje","delete_message","del"]
	#tts:
]
const pos = "/Config/e_commands.mega-file"
const comando = preload("res://Panel de control/Configuracion/Comandos especiales/comando.tscn")

func _ready():
	data = Tools.cargar(pos)
	 # Actualizar data
	var n = data.size()
	if n > sctructure.size():
		data = []
		n = 0
	if n < sctructure.size():
		while n < sctructure.size():
			data.append(["",0,PoolStringArray([])]) #[nombre=activado,puntos,aliases]
			n += 1
		Tools.guardar(pos,data)
	
	reload()

func reload():
	Tools.delete_childs($PanelContainer/ScrollContainer/vbox)
	var n = 0
	while n < data.size():
		var c = comando.instance()
		c.text = sctructure[n][0]
		c.pressed = false if data[n][0] == "" else true
		if c.pressed:
			Tools.bot.purge_command(data[n][0])
			Tools.bot.add_command(data[n][0],Tools.bot,sctructure[n][1])
			Tools.bot.add_aliases(data[n][0],data[n][2])
			Tools.bot.set(sctructure[n][1],data[n][1])
		c.get_node("button").connect("pressed",self,"edit",[c])
		c.connect("pressed",self,"activate",[c])
		$PanelContainer/ScrollContainer/vbox.add_child(c)
		n += 1
	

var actual
func edit(node):
	actual = node
	var p = node.get_index()
	$edit/v/titulo.text = data[p][0]
	$edit/v/alias.array = data[p][2]
	$edit/v/alias._update()
	$edit/v/hbox/Puntos.pressed = false if data[p][1] == 0 else true
	_on_Puntos_pressed()
	$edit/v/coste.value = data[p][1]
	
	$edit.popup_centered()

func activate(node):
	var p = node.get_index()
	if node.pressed:
		data[p][0] = sctructure[p][2] 
	else: 
		Tools.bot.purge_command(data[p][0])
		data[p][0] = ""
	Tools.guardar(pos,data)
	reload()

func _on_vvbox_item_rect_changed():
	$edit/v.rect_size = Vector2(0,0)
	$edit.rect_min_size = $edit/v.rect_size + Vector2(20,20)
	$edit.rect_size = $edit.rect_min_size

func _on_Puntos_pressed():
	$edit/v/coste.visible = $edit/v/hbox/Puntos.pressed

func _on_Comandos_visibility_changed():
	reload()

func _on_guardar_pressed():
	var p = actual.get_index()
	data[p][0] = $edit/v/titulo.text
	data[p][1] = $edit/v/coste.value if $edit/v/hbox/Puntos.pressed else 0
	data[p][2] = $edit/v/alias.array
	$edit.hide()
	reload()
	Tools.guardar(pos,data)
