extends Control



func _on_Animacion_animation_finished(anim_name):
	get_parent().add_child(preload("res://Setup scenes/Bot_mode.tscn").instance())
