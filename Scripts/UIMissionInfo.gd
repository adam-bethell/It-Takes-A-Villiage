extends Control

onready var _labels = [
	$HBoxContainer/Mission1,
	$HBoxContainer/Mission2,
	$HBoxContainer/Mission3,
	$HBoxContainer/Mission4,
]

func _on_missions_updated(mission_data):
	for i in mission_data.size():
		var mission = mission_data[i]
		var text = mission["name"]
		var equiped = mission["equiped_items"]
		for requirement in mission["requirements"]:
			if equiped.has(requirement):
				text += "\n[x] "
			else:
				text += "\n[ ] "
			text += Objectives.ITEM_INFO[requirement]["label"]
		text += "\n" + Objectives.BUILDING_INFO[mission["location"]]["label"]
		_labels[i].text = text
