extends Node

var enabled = false
var citizen = null
var citizen_tasks = null

var _current_task = null

func _process(_delta):
	if not enabled:
		return
	
	if _current_task == null:
		next_task()
	elif _current_task["type"] == "move":
		# Check on the move task
		var position = citizen.global_transform.origin
		var destination = _current_task["destination"]
		if position.distance_to(destination) < Globals.ACTION_DISTANCE:
			next_task()
	elif _current_task["type"] == "equip":
		# Attempt the equip task
		var result = Globals.game_controller.equip_item(
			citizen.name,
			_current_task["item"]
		)
		if result:
			next_task()
	elif _current_task["type"] == "drop":
		# Attempt the drop task
		var result = Globals.game_controller.drop_item(
			citizen.name,
			_current_task["item"]
		)
		if result:
			next_task()

func next_task():
	_current_task = citizen_tasks.get_next_task()
	if _current_task != null and _current_task["type"] == "move":
		Globals.game_controller.set_citizen_destination(
			citizen.name,
			_current_task["destination"],
			_current_task["is_walking"]
		)

func time_loop():
	_current_task = null
