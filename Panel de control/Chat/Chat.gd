extends Control

func _ready():
	#$RichTextLabel.push_color(Color("#984646"))
	$RichTextLabel.bbcode_text = "[color=#594743]- Comienzo del chat -[/color]"

func _on_bot_chat_message(sender_data, message):
	var color = (Color(sender_data.tags["color"]) + Color8(139,88,0,0))
	color = "#" + color.to_html()
	print(color)
	$RichTextLabel.bbcode_text += (" \n [color=%s]" % color) + sender_data.tags["display-name"] + ":[/color] " + message

func _on_bot_chat(message,data):
	if message == "":
		return
	if message[0] == "/":
		return
	$RichTextLabel.bbcode_text += " \n [color=%s]" %data[0] + "BOT" + ": " + message + "[/color] "
