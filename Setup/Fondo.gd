extends Node2D
var velocity = Vector2(10,0)
var viewport
var fondito
var lists = []

func _ready():
	fondito = preload("res://Setup/Fondito.tscn")
	viewport = get_tree().root
	anterior = get_global_mouse_position()#viewport.get_mouse_position()

var anterior
var direccion = Vector2(300,225)
func _process(delta):
	var temp = get_global_mouse_position()#viewport.get_mouse_position()
	velocity += temp - anterior
	anterior = temp
	
	velocity = ((velocity - direccion) * 0.95 ) + direccion
	
	position += velocity * delta * 0.2

func quitar(pos):
	lists.remove(lists.find(pos))

func nueva(pos):
	if lists.find(pos) != -1:
		return
	var a = fondito.instance()
	a.position = pos
	lists.append( pos)
	add_child(a)
	move_child(a,0)
