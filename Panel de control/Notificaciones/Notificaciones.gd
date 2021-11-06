extends Label

var vbox : VBoxContainer
var notificacion = preload("res://Panel de control/Notificaciones/notificacion.tscn")
var stylebox = preload("res://Panel de control/Notificaciones/stylebox.tres")
var first = true

const colors = {
	NORMAL = Color("31384b"),
	RED = Color("4b2a2a"),
	YELLOW = Color("848648"),
	GREEN = Color("48864a"),
	BLUE = Color("488683")
}


func _ready():
	vbox = $scroll/vbox

func add_notification(title,_text,color=colors.NORMAL,image=null):
	if first:
		Tools.delete_childs(vbox)
		first = false
	var instance = notificacion.instance()
	instance.get_node("vbox/title").text = title
	instance.get_node("vbox/hbox/text").text = _text
	var _stylebox = stylebox.duplicate()
	_stylebox.bg_color = color
	instance.set("custom_styles/panel",_stylebox)
	if image != null:
		Carga._load(image,instance.get_node("vbox/hbox/image"))
	else:
		instance.get_node("vbox/hbox/image").free()
	vbox.add_child(instance)
	vbox.move_child(instance,0)
