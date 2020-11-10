extends Node

var citizen_ai = -1

var _time = 0
var _tasks = []
var _task_index = 0

func _process(delta):
	_time += delta

func log_movement(position, destination, is_walking):
	if _tasks.size() > 0:
		var previous_task = _tasks.back()
		previous_task["destination"] = position
	
	_tasks.push_back({
		"time": _time,
		"destination": destination,
		"is_walking": is_walking,
	})
	print(_tasks.size())
	
func log_equip(item):
	_tasks.push_back({
		"type": "equip",
		"item": item,
	})
	print(_tasks.size())
	
func log_drop():
	pass

	
func get_next_move_task():
	print(_tasks.size())
	if _task_index < _tasks.size():
		var task = _tasks[_task_index]
		print(task.has("destination"))
		if task.has("destination") and task["time"] <= _time:
			_task_index += 1
			return task
	return null
	
func get_next_item_task():
	print(_tasks.size())
	if _task_index < _tasks.size():
		var task = _tasks[_task_index]
		if task.has("item"):
			_task_index += 1
			return task
	return null
	
func time_loop():
	_task_index = 0
	_time = 0
