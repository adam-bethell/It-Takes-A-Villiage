extends Control

onready var game_controller = get_node("../../GameBoard")
onready var item_button_prefab = preload("res://Prefabs/UI/ItemButton.tscn")

var _citizen = null
var _buttons = []

func follow_citizen(citizen_to_follow):
	_citizen = citizen_to_follow
	_citizen.connect("citizen_updated", self, "update_info")
	update_info()

func update_info():
	_remove_all_item_buttons()
	for item in _citizen.get_inventory():
		_create_item_button(item)

func _remove_all_item_buttons():
	for button in $ItemListContainer/ItemList.get_children():
		$ItemListContainer/ItemList.remove_child(button)
	_buttons = []

func _create_item_button(item):
	var button = item_button_prefab.instance()
	button.item = item
	button.text = Objectives.ITEM_INFO[item]["label"]
	button.disabled = false
	button.connect("item_pressed", self, "_on_item_pressed")
	$ItemListContainer/ItemList.add_child(button)
	
func _on_item_pressed(item):
	game_controller.drop_player_item(item)
