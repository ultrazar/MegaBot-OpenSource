extends Control

var root


func _ready():
	root = get_tree().root

func _process(delta):
	rect_position = root.size / 2
