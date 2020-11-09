extends Node

signal building_selected(this_building)
signal building_updated(this_building)

export(Objectives.BUILDINGS) var building_type 
export(int) var building_id

onready var entrance_position = $Entrance.global_transform.origin

var _inventory = []

func _ready():
	for item in Objectives.BUILDING_INFO[building_type]["items"]:
		_inventory.push_back({
			"item": item,
			"available": true,
		})

func selected():
	emit_signal("building_selected", self)
	
func get_inventory():
	var inventory = []
	for item in _inventory:
		inventory.push_back(item["item"])
	return inventory

func get_inventory_details():
	return _inventory
