extends Node

onready var _buildings = get_node("../BoardNavMesh/Buildings")

var _dead_drops = []
var _other_locations = []

var _my_buildings = []


func _ready():
	for building in _buildings.get_children():
		if building.building_type == Objectives.BUILDINGS.DEAD_DROP:
			_dead_drops.push_back(building)
		else:
			_other_locations.push_back(building)

func generate_tasks (citizen, citizen_tasks):
	_shuffle_buildings()
	_choose_buildings()
	
	citizen_tasks.log_wait(randi() % 5 + 1)
	
	var closest_building = _pop_closest_other_location(citizen.global_transform.origin)
	citizen_tasks.log_movement(
		citizen.global_transform.origin,
		closest_building.entrance_position,
		true
	)
	
	_order_buildings()
	var previous_building = closest_building
	for building in _my_buildings:
		citizen_tasks.log_wait(randi() % 5 + 1)
		citizen_tasks.log_movement(
			previous_building.entrance_position,
			building.entrance_position,
			true
		)
	
	
func _shuffle_buildings():
	randomize()
	_dead_drops.shuffle()
	_other_locations.shuffle()
	
func _choose_buildings():
	for i in range(2):
		_my_buildings.push_back(_dead_drops[i])
	for i in range(4):
		_my_buildings.push_back(_other_locations[i])
	
func _pop_closest_other_location(origin):
	var closest_distance = 99999
	var closest_building = null
	for building in _my_buildings:
		if building.building_type == Objectives.BUILDINGS.DEAD_DROP:
			continue
		var distance = origin.distance_to(building.entrance_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_building = building
	_my_buildings.erase(closest_building)
	return closest_building

func _order_buildings():
	var _my_buildings_ordered = []
	var _my_dead_drops = []
	for building in _my_buildings:
		if building.building_type != Objectives.BUILDINGS.DEAD_DROP:
			_my_buildings_ordered.push_back(building)
		else:
			_my_dead_drops.push_back(building)
	
	var order = randi() % 3
	if order == 0:
		# dead drops at 0 and 2
		_my_buildings_ordered.insert(0, _my_dead_drops[0])
		_my_buildings_ordered.insert(2, _my_dead_drops[1])
		
	elif order == 1:
		# dead drops and 0 and 3
		_my_buildings_ordered.insert(0, _my_dead_drops[0])
		_my_buildings_ordered.insert(3, _my_dead_drops[1])
	else:
		# dead drops and 1 and 3
		_my_buildings_ordered.insert(1, _my_dead_drops[0])
		_my_buildings_ordered.insert(3, _my_dead_drops[1])
	
	_my_buildings = _my_buildings_ordered
