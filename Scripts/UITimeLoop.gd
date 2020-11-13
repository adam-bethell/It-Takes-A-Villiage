extends Button

func _ready():
	if not get_tree().is_network_server():
		get_node("../UI/TimeLoop").hide()
