extends LineEdit
export var lowercase :bool

func _enter_tree():
	connect("text_changed",self,"main")

func main(_text):
	var pos = caret_position
	if lowercase:
		text = _text.to_lower()
		
	
	
	caret_position = pos
