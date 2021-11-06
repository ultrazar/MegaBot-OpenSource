extends Node
signal recarga_de_puntos(usuario)

func _ready():
	TwitchApi.pubsub("channel-points-channel-v1." + Tools.padre.config["channel_data"]["id"])
	TwitchApi.connect("reward_redeemed",self,"canjeo")

func user_entered(user):
	pass


func _on_canjeo_timeout():
	pass

func canjeo(_data):
	if _data.size() == 3:
		push_error(str(_data))
		return
	var data = _data#["data"]
	if data.size() != 0:
		#data = data[0]
		Tools.padre.notif.add_notification("Canjeo","%s ha canjeado %s de %s puntos" % [data["user"]["display_name"],data["reward"]["title"],str(data["reward"]["cost"])])
		if get_parent().users.has(data["user"]["login"]):
			
			get_parent().users[data["user"]["login"]]["puntos"] += data["reward"]["cost"]
			emit_signal("recarga_de_puntos",data["user"]["login"])
			TwitchApi.update_redemption(Tools.padre.config["points_reward"]["id"],data["id"],"_temp",self)
			print("añadidos")
			return
		else:
			get_parent()._on_bot_user_joined(data["user"]["login"],data["reward"]["cost"])
			print("registrandolo")
			return

func _temp(data):
	print(data)


