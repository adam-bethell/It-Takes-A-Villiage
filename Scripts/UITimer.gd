extends Label

var _time = 0

func _process(delta):
	_time += delta
	text = str(_time)

func _on_TimeLoop_pressed():
	_time = 0
