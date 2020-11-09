extends Control

onready var game_controller = get_node("../../GameBoard")

var _objective_items = []
var _selected_building = null
var _buttons = []
var _inventory = []


func _on_building_selected(building):
	_selected_building = building
	$ItemList/Label.text = Objectives.BUILDING_INFO[_selected_building.building_type]["label"]
	_inventory = _selected_building.get_inventory_details()
	_buttons = [
		$ItemList/Button1,
		$ItemList/Button2,
		$ItemList/Button3,
	]
	for i in range(3):
		_buttons[i].text = Objectives.ITEM_INFO[_inventory[i]["item"]]["label"]
		_buttons[i].disabled = not _inventory[i]["available"]


func _on_building_updated(building):
	if building != _selected_building:
		return
	_inventory = building.get_inventory()
	for i in range(3):
		_buttons[i].disabled = not _inventory[i]["available"]


func _on_item_pressed(index):
	if _selected_building == null:
		return
	game_controller.equip_player_item(_inventory[index]["item"])
