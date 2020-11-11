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
