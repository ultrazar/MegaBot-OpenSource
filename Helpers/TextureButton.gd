extends TextureButton #Pequeño script para que un texturebutton se oscurezca al presionar/hover
func _enter_tree():
	self.connect("draw",self,"draw")

func draw():
	match get_draw_mode(): 
		DRAW_NORMAL:
			modulate = Color(1,1,1)
		DRAW_HOVER:
			modulate = Color(0.8,0.8,0.8)
		DRAW_HOVER_PRESSED,DRAW_PRESSED:
			modulate = Color(0.5,0.5,0.5)
