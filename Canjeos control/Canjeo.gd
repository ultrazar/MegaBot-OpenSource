extends MarginContainer
var data

func init(image,color,text,_data):
	Carga._load(image,$Panel/Imagen)
	$Panel.self_modulate = color
	$Panel/Texto.text = text
	var style = $Panel/Texto.get("custom_styles/normal").duplicate()
	style.set_corner_radius_all(2)
	var _color = Color(color) - Color(0.6,0.6,0.6,0)
	_color.a = 1
	style.set_bg_color(_color)
	$Panel/Texto.set('custom_styles/normal', style)
	data = _data

func _on_Panel_mouse_entered():
	$Animacion.play("animacion")


func _on_Panel_mouse_exited():
	$Animacion.play_backwards("animacion")


func _on_Panel_pressed():
	get_parent().get_parent().get_parent().pressed(self)
