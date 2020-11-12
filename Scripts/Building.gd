extends Node

export(Objectives.BUILDINGS) var building_type 

onready var entrance_position = $Entrance.global_transform.origin

var building_id

var _inventory = []

func _ready():
	for item in Objectives.BUILDING_INFO[building_type]["default_items"]:
		_inventory.push_back({
			"item": item,
			"available": true,
		})

func selected():
	get_parent().on_building_selected(self)
	
func get_inventory():
	var inventory = []
	for item in _inventory:
		inventory.push_back(item["item"])
	return inventory

func get_inventory_details():
	return _inventory
	
func equip_item(item):
	assert(get_tree().is_network_server())
	_inventory.push_back({
		"item": item,
		"available": true,
	})
	rpc("_rpc_update_inventory", _inventory)
	
func drop_item(item):
	assert(get_tree().is_network_server())
	if building_type != Objectives.BUILDINGS.DEAD_DROP:
		return
	var item_to_remove = _find_item(item)
	_inventory.erase(item_to_remove)
	rpc("_rpc_update_inventory", _inventory)

remotesync func _rpc_update_inventory(inventory):
	_inventory = inventory
	get_parent().on_building_updated(self)

func has_item(item):
	if _find_item(item) != null:
		return true
	return false

func _find_item(item):
	for item_details in _inventory:
		if item_details["item"] == item:
			return item_details
	return null

func time_loop():
	_inventory.clear()
	for item in Objectives.BUILDING_INFO[building_type]["default_items"]:
		_inventory.push_back({
			"item": item,
			"available": true,
		})
