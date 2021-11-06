extends Panel

func _ready():
	$spinbox.value = Tools.padre.config["users"]["expires"]
	$notif.pressed = Tools.padre.config["users"]["notif"]

func _on_spinbox_value_changed(value):
	Tools.padre.config["users"]["expires"] = value


func _on_notif_pressed():
	Tools.padre.config["users"]["notif"] = not Tools.padre.config["users"]["notif"]
