extends Control

func _ready():
	hide()

func _on_player_victory(name, objective):
	var text = name + " has compelted \"" + objective["name"] + "\"!"
	$Label.text = text
	show()
