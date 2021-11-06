extends Node2D

#TODO: Optimizar el funcionamiento del fondo

func _on_VisibilityNotifier2D_viewport_exited(viewport):
	get_parent().quitar(position)
	queue_free()


func entered(viewport,pos):
	var _pos = pos + Vector2(2560,1440)
	get_parent().nueva(_pos + position)
