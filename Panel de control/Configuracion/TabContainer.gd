extends TabContainer

func _ready():
	if !Tools.padre.config["puntos"]:
		$"Puntos del bot".free()
