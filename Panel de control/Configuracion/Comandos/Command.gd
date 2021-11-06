extends Control

var comando : String
var respuesta : String
var data : Array

func _ready():
	var nodo = get_parent().get_parent().get_parent().get_parent()
	$edit.connect("pressed",nodo,"editar",[self])
	$delete.connect("pressed",nodo,"eliminar",[self])
