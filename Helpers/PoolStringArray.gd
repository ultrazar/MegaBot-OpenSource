extends Panel
export var lowercase : bool
export var array : PoolStringArray = []
var single : HBoxContainer


func _ready():
	if lowercase:
		$scroll/vbox/hbox/label.lowercase = true
	single = $scroll/vbox/hbox.duplicate()
	$scroll/vbox/hbox.queue_free()

func _update(_array:PoolStringArray=array):
	array=_array
	for a in ($scroll/vbox.get_child_count() -1):
		$scroll/vbox.get_child(a).queue_free()
	for a in _array:
		var main = single.duplicate()
		$scroll/vbox.add_child(main)
		main.get_node("label").text = a
		main.get_node("eliminar").connect("pressed",self,"delete",[main])
		main.get_node("label").connect("text_changed",self,"modify",[main])
		$scroll/vbox.move_child(main,$scroll/vbox.get_child_count() - 2)

func delete(node):
	array.remove(node.get_index())
	node.queue_free()

func modify(text,node):
	array[node.get_index()] = text

func _on_mas_pressed():
	var m = single.duplicate()
	$scroll/vbox.add_child(m)
	$scroll/vbox.move_child(m,$scroll/vbox.get_child_count() - 2)
	array.append("")
	m.get_node("label").text = ""
	m.get_node("eliminar").connect("pressed",self,"delete",[m])
	m.get_node("label").connect("text_changed",self,"modify",[m])
