extends Control

func _ready():
	hide()

func _on_player_victory(name, objective):
	var text = name + " has completed \"" + objective["name"] + "\"!"
	$Label.text = text
	show()
