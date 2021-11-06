extends Control

func alerta_gif(tiempo=5):
	$animaciones.play("gif")
	yield(get_tree().create_timer(tiempo),"timeout")
	$animaciones.play_backwards("gif")


func sonido(sonido):
	$sonido.stream = sonido
	$sonido.play()
