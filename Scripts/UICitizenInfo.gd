extends Control


var _citizen = null


# Called when the node enters the scene tree for the first time.
func _ready():
	#citizen = get_node("../../GameBoard/Citizens").get_child(0).get_node("UITarget")
	pass # Replace with function body.


func _process(delta):
	if _citizen == null:
		hide()
		return
	
	var world_pos = _citizen.get_node("UITarget").global_transform.origin
	var screen_pos = get_node("../../../CameraController/Camera").unproject_position(world_pos)
	rect_global_position = screen_pos
	show()


func follow_citizen(citizen_to_follow):
	_citizen = citizen_to_follow
	_citizen.connect("citizen_updated", self, "update_info")
	update_info()

func update_info():
	var info_text = "My Citizen\n__________"
	for item in _citizen.get_inventory():
		info_text += "\n" + Objectives.ITEM_INFO[item]["label"]
	$Label.text = info_text
