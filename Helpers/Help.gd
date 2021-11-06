extends TextureButton

export var text : String 
export var title : String

func _pressed():
	Tools.ventana(title,text)
	
func _on_Control_draw():
	match get_draw_mode(): 
		DRAW_NORMAL:
			modulate = Color(1,1,1)
		DRAW_HOVER:
			modulate = Color(0.8,0.8,0.8)
		DRAW_HOVER_PRESSED,DRAW_PRESSED:
			modulate = Color(0.5,0.5,0.5)

