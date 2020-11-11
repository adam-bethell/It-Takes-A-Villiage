extends Button

signal item_pressed(item)

var item = null

func _pressed():
	emit_signal("item_pressed", item)
