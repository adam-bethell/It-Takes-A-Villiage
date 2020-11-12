extends Control

onready var game_controller = get_node("../../GameBoard")
onready var item_button_prefab = preload("res://Prefabs/UI/ItemButton.tscn")

var _objective_items = []
var _selected_building = null
var _buttons = []
var _inventory = []


func _on_building_selected(building):
	_selected_building = building
	$Label.text = Objectives.BUILDING_INFO[_selected_building.building_type]["label"]
	_on_building_updated(building)
	
func _on_building_updated(building):
	if building != _selected_building:
		return
	_remove_all_item_buttons()
	_inventory = _selected_building.get_inventory_details()
	for item_details in _inventory:
		_create_item_button(item_details)

func _on_item_pressed(item):
	if _selected_building == null:
		return
	game_controller.equip_player_item(item)

func _remove_all_item_buttons():
	for button in $ItemListContainer/ItemList.get_children():
		$ItemListContainer/ItemList.remove_child(button)
	_buttons = []

func _create_item_button(item_details):
	var item = item_details["item"]
	var is_disabled = not item_details["available"]
	var button = item_button_prefab.instance()
	button.item = item
	button.text = Objectives.ITEM_INFO[item]["label"]
	button.disabled = is_disabled
	button.connect("item_pressed", self, "_on_item_pressed")
	$ItemListContainer/ItemList.add_child(button)
	
