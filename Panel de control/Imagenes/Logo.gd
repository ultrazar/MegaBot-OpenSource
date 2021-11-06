extends TextureRect
export var url : String

func _ready():
	var nodo = get_tree().current_scene
	Carga._load(nodo.config["channel_data"][url],self)
