extends Navigation

signal missions_updated(mission_data)
signal player_victory(name, objective)

onready var citizen_tasks_node = preload("res://Prefabs/CitizenTasks.tscn")
onready var citizen_ai_node = preload("res://Prefabs/CitizenAI.tscn")

var _mission_data = []
var _citizen_tasks = {}
var _citizen_ai = {}

#| Create citizens
func _ready():
	Globals.game_controller = self
	if get_tree().is_network_server():
		# Create citizens
		for i in range(16):
			var pos = Vector3(3 * i, 0, 0)
			var citizen_id = $Citizens.add_citizen(pos)
			var citizen_tasks = citizen_tasks_node.instance()
			_citizen_tasks[citizen_id] = citizen_tasks
			get_node("../CitizenAI").add_child(citizen_tasks)
			
		# Assign player citizens and objectives
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
		
		# Give AI to non-player citizens
		for citizen in $Citizens.get_children():
			var citizen_ai = citizen_ai_node.instance()
			citizen_ai.citizen = citizen
			citizen_ai.citizen_tasks = _citizen_tasks[citizen.citizen_id]
			_citizen_ai[citizen.citizen_id] = citizen_ai
			get_node("../CitizenAI").add_child(citizen_ai)
			if citizen.player_id == -1:
				citizen_ai.enabled = true
			else:
				citizen_ai.enabled = false
	
#| Set citizen destination
func set_player_citizen_destination(dest, walk):
	var id = get_tree().get_network_unique_id()
	var citizen_id = $Citizens.get_citizen_by_player_id(id).citizen_id
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
	var citizen = $Citizens.get_citizen_by_citizen_id(citizen_id)
	citizen.set_destination(dest, walk)
	$Citizens.sync_positions()
	if citizen.player_id != -1: 
		# Record tasks for player controlled citizens
		_citizen_tasks[citizen_id].log_movement(citizen.global_transform.origin, dest, walk)
	
#| Equip item
func equip_player_item(item):
	var id = get_tree().get_network_unique_id()
	var citizen_id = $Citizens.get_citizen_by_player_id(id).citizen_id
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
	if dist < Globals.ACTION_DISTANCE:
		citizen.equip_item(item)
		_update_missions()
		if citizen.player_id != -1: 
			# Record tasks for player controlled citizens
			_citizen_tasks[citizen_id].log_equip(item)
		return true
	return false


func _update_missions():
	assert(get_tree().is_network_server())
	# Update mission data
	for mission in _mission_data:
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
		if dist < Globals.ACTION_DISTANCE:
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
	assert(get_tree().is_network_server())
	# Call time_loop() in children
	$Citizens.time_loop()
	for citizen_tasks in _citizen_tasks.values():
		citizen_tasks.time_loop()
	
	# Assign new player citizens
	for id in Network.player_data:
		$Citizens.assign_citizen_to_player(id)
	_update_missions()
	
	# Enable / diable AI
	for citizen_id in _citizen_ai:
		var citizen = $Citizens.get_citizen_by_citizen_id(citizen_id)
		_citizen_ai[citizen_id].time_loop()
		if citizen.player_id == -1:
			# Add AI for non-player citizens
			_citizen_ai[citizen_id].enabled = true
		else:
			# Remove AI for player citizens
			_citizen_ai[citizen_id].enabled = false
	
	
