extends Control

func _enter_tree():
	$info.connect("pressed",get_parent().get_parent().get_parent().get_parent(),"info",[self])
	$eliminar.connect("pressed",get_parent().get_parent().get_parent().get_parent(),"eliminar",[self])
"""
func bot():
	$desbot.show()
	$desbot.connect("pressed",get_parent().get_parent().get_parent().get_parent(),"desbot",[self])
"""
