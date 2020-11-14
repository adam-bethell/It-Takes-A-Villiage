extends Button

func _ready():
	if not get_tree().is_network_server():
		hide()
