extends Panel



func _on_Canjeos_control_selected(button_data):
	Tools.padre.config["points_reward"] = button_data
	$scroll/vbox/label1.text = "El canjeo actual es: %s" % button_data["title"]

func _ready():
	$scroll/vbox/label1.text = "El canjeo actual es: %s" % Tools.padre.config["points_reward"]["title"]
