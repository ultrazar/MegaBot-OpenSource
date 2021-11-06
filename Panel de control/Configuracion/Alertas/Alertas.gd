extends Panel
var nodo : Label
var padre : Control

func _ready():
	nodo = Tools.padre.get_node("CanvasLayer/titulo")
	padre = Tools.padre
	var vector2 = padre.config["alertas"]["resolucion"]
	$resolucion/x.text = str(vector2[0])
	$resolucion/y.text = str(vector2[1])
	resolution_changed("")

func resolution_changed(new_text):
	if nodo == null:
		return
	var vector2 = [int($resolucion/x.text),int($resolucion/y.text)]
	
	nodo.margin_right = vector2[0] + 21
	nodo.get_node("alertas").margin_bottom = vector2[1]
	padre.config["alertas"]["resolucion"] = vector2
	
