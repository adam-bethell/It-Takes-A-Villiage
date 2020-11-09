extends Navigation

signal missions_updated(mission_data)
signal player_victory(name, objective)

const BUILDING_RANGE = 1.0

var _mission_data = []

#| Create citizens
func _ready():
	Globals.game_controller = self
	if get_tree().is_network_server():
		for i in range(16):
			var pos = Vector3(3 * i, 0, 0)
			$Citizens.add_citizen(pos)
			
		var objectives = Objectives.MISSIONS
		var o = 0
		randomize()
		objectives.shuffle()
		for id in Network.player_data:
			$Citizens.assign_citizen_to_player(id)
			var objective = objectives[o]
			objective["player_id"] = id
			objective["equiped_items"] = []
			_mission_data.push_back(objective)
			o += 1
			
		_mission_data.shuffle()
		_update_missions()
	
#| Set citizen destination
func set_player_citizen_destination(dest, walk):
	var id = get_tree().get_network_unique_id()
	var citizen_id = $Citizens.get_citizen_by_player_id(id).name
	set_citizen_destination(citizen_id, dest, walk)

func set_citizen_destination(citizen_id, dest, walk):
	if get_tree().is_network_server():
		_set_citizen_destination(citizen_id, dest, walk)
	else:
		rpc_id(1, "_rpc_set_citizen_destination", citizen_id, dest, walk)
		
remote func _rpc_set_citizen_destination(citizen_id, dest, walk):
	var id = get_tree().get_rpc_sender_id()
	assert(get_tree().is_network_server())
	if $Citizens.get_citizen_by_citizen_id(citizen_id).player_id != id:
		assert(false)
		return
	_set_citizen_destination(citizen_id, dest, walk)
	
func _set_citizen_destination(citizen_id, dest, walk):
	assert(get_tree().is_network_server())
	$Citizens.get_citizen_by_citizen_id(citizen_id).set_destination(dest, walk)
	$Citizens.sync_positions()
	
#| Equip item
func equip_player_item(item):
	var id = get_tree().get_network_unique_id()
	var citizen_id = $Citizens.get_citizen_by_player_id(id).name
	equip_item(citizen_id, item)

func equip_item(citizen_id, item):
	if get_tree().is_network_server():
		return _equip_item(citizen_id, item)
	else:
		rpc_id(1, "_rpc_equip_item", citizen_id, item)

remote func _rpc_equip_item(citizen_id, item):
	var id = get_tree().get_rpc_sender_id()
	assert(get_tree().is_network_server())
	if $Citizens.get_citizen_by_citizen_id(citizen_id).player_id != id:
		assert(false)
		return
	_equip_item(citizen_id, item)
	
func _equip_item(citizen_id, item):
	assert(get_tree().is_network_server())
	var citizen = $Citizens.get_citizen_by_citizen_id(citizen_id)
	var building = $BoardNavMesh/Buildings.get_nearest_building(citizen.global_transform.origin)
	var dist = citizen.global_transform.origin.distance_to(building.entrance_position)
	if dist < BUILDING_RANGE:
		citizen.equip_item(item)
		_update_missions()
		return true
	return false

func _update_missions():
	assert(get_tree().is_network_server())
	# Update mission data
	for mission in _mission_data:
		print($Citizens.get_citizen_by_player_id(mission["player_id"]).name)
		var inventory = $Citizens.get_citizen_by_player_id(mission["player_id"]).get_inventory()
		for requirement in mission["requirements"]:
			if inventory.has(requirement):
				mission["equiped_items"].push_back(requirement)
	# Strip out info that could be used for cheating
	#var safe_mission_data = _mission_data.duplicate()
	#for mission in safe_mission_data:
		#mission["player_id"] = ""
	# Sync mission data
	rpc("_rpc_missions_updated", _mission_data)
	emit_signal("missions_updated", _mission_data)
	
remote func _rpc_missions_updated(mission_data):
	assert(not get_tree().is_network_server())
	_mission_data = mission_data
	emit_signal("missions_updated", _mission_data)

#| Complete a mission
func _on_mission_complete_pressed():
	if get_tree().is_network_server():
		_complete_mission(1)
	else:
		rpc_id(1, "_rpc_complete_mission")

remote func _rpc_complete_mission():
	assert(get_tree().is_network_server())
	var id = get_tree().get_rpc_sender_id()
	_complete_mission(id)
	
func _complete_mission(id):
	assert(get_tree().is_network_server())
	print(str(id) + " is attempting to complete mission")
	# Get objective
	var objective = null
	for mission in _mission_data:
		if mission["player_id"] == id:
			 objective = mission
	# Get / check inventory
	var equiped = objective["equiped_items"]
	for requirement in objective["requirements"]:
		if not equiped.has(requirement):
			return
	print("inventory checked")
	# Get / check positions
	var in_range = false
	var citizen_position = $Citizens.get_citizen_by_player_id(id).global_transform.origin
	var building_type = objective["location"]
	print("Building type: " + str(building_type))
	var buildings = $BoardNavMesh/Buildings.get_buildings(building_type)
	print("Found " + str(buildings.size()) + " buildings")
	for building in buildings:
		var dist = citizen_position.distance_to(building.entrance_position)
		print(dist)
		if dist < BUILDING_RANGE:
			in_range = true
			break
	if not in_range:
		print("building not in range")
		return
	print("building in range checked")
	
	rpc("_rpc_player_won", Network.player_data[id], objective)
	
remotesync func _rpc_player_won(name, objective):
	emit_signal("player_victory", name, objective)


func _on_time_loop():
	$Citizens.time_loop()
