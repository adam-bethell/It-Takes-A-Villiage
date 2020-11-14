extends Node

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
		"type": "move",
		"time": _time,
		"destination": destination,
		"is_walking": is_walking,
	})
	
func log_equip(item):
	_tasks.push_back({
		"type": "equip",
		"time": 0.0, 
		"item": item,
	})
	
func log_drop(item):
	_tasks.push_back({
		"type": "drop",
		"time": 0.0,
		"item": item,
	})
	
func log_wait(wait_time):
	_tasks.push_back({
		"type": "wait",
		"wait_time": wait_time,
		"time": null,
	})
	
func get_next_task():
	if _task_index < _tasks.size():
		var task = _tasks[_task_index]
		# Wait tasks
		if task["type"] == "wait":
			if task["time"] == null:
				task["time"] = _time + task["wait_time"]
			elif task["time"] <= _time:
				_task_index += 1
		# Other tasks
		elif task["time"] <= _time:
			_task_index += 1
			return task
	return null

func time_loop():
	_task_index = 0
	_time = 0

func clear():
	_tasks.clear()
	_task_index = 0
