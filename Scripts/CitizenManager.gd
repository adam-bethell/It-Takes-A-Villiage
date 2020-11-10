extends Spatial
#| Citizen Manager is for the static/singleton methods of Citizen

var _mesh_index = 0
var _meshes = [
	"res://Models/Citizens/actress.tres",
	"res://Models/Citizens/astronaut.tres",
	"res://Models/Citizens/arctic_researcher.tres",
	"res://Models/Citizens/biker.tres",
	"res://Models/Citizens/bro.tres",
	"res://Models/Citizens/builder.tres",
	"res://Models/Citizens/casual.tres",
	"res://Models/Citizens/cowboy.tres",
	"res://Models/Citizens/cultist.tres",
	"res://Models/Citizens/farmer.tres",
	"res://Models/Citizens/gardener.tres",
	"res://Models/Citizens/interviewee.tres",
	"res://Models/Citizens/lifeguard.tres",
	"res://Models/Citizens/mafioso.tres",
	"res://Models/Citizens/manager.tres",
	"res://Models/Citizens/office_worker.tres",
	"res://Models/Citizens/writer.tres",
	"res://Models/Citizens/scientist.tres",
	"res://Models/Citizens/rocker.tres",
]
onready var citizen_node = preload("res://Prefabs/Citizen.tscn")
onready var citizen_info_node = preload("res://Prefabs/CitizenInfo.tscn")
var _citizen_id = 0
var _citizens = []

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	_meshes.shuffle()
	
	
func get_citizen_by_player_id(player_id):
	for citizen in get_children():
		if citizen.player_id == player_id:
			return citizen

func get_citizen_by_citizen_id(citizen_id):
	for citizen in get_children():
		if citizen.name == str(citizen_id):
			return citizen

func get_mesh_path():
	var path = _meshes[_mesh_index]
	_mesh_index += 1
	if _mesh_index == _meshes.size():
		_mesh_index = 0
		_meshes.shuffle()
	return path
	
func add_citizen(position):
	var mesh_path = get_mesh_path()
	var citizen_id = _citizen_id
	rpc("_rpc_add_citizen", mesh_path, position)
	return citizen_id

remotesync func _rpc_add_citizen(mesh_path, position):
	# Add game object
	var citizen = citizen_node.instance()
	citizen.set_name(str(_citizen_id))
	citizen.citizen_id = _citizen_id
	_citizen_id += 1
	citizen.set_mesh_path(mesh_path)
	citizen.start_position = position
	add_child(citizen)
	citizen.global_transform.origin = position
	if get_tree().is_network_server():
		_citizens.push_back(citizen)
		_citizens.shuffle()


func assign_citizen_to_player(id):
	assert(get_tree().is_network_server())
	# Add UI if citizen belongs to this player
	var citizen = _citizens.pop_front()
	citizen.owner_id = id
	citizen.player_id = id
	if id == 1:
		var info = citizen_info_node.instance()
		info.follow_citizen(citizen)
		get_node("../../UI/Diagetic").add_child(info)
	else:
		rpc_id(id, "_rpc_assign_citizen_to_player", citizen.name)
	return citizen.name

remote func _rpc_assign_citizen_to_player(citizen_id):
	var citizen = get_citizen_by_citizen_id(citizen_id)
	var id = get_tree().get_network_unique_id()
	citizen.owner_id = id
	citizen.player_id = id
	var info = citizen_info_node.instance()
	info.follow_citizen(citizen)
	get_node("../../UI/Diagetic").add_child(info)


func set_player_citizen_destination(id, dest, walk):
	for citizen in get_children():
		if citizen.player_id == id:
			citizen.set_destination(dest, walk)
	
	
func sync_positions():
	var citizen_data = {}
	for citizen in get_children():
		citizen_data[citizen.name] = {
			"position": citizen.global_transform.origin,
			"nav_path": citizen.nav_path,
			"nav_path_index": citizen.nav_path_index,
			"is_walking": citizen.is_walking,
		}
		
	rpc("_rpc_sync_positions", citizen_data)
	
	
remote func _rpc_sync_positions(citizen_data):
	for citizen_name in citizen_data:
		var citizen = get_node(citizen_name)
		var data = citizen_data[citizen_name]
		citizen.global_transform.origin = data["position"]
		citizen.nav_path = data["nav_path"]
		citizen.nav_path_index = data["nav_path_index"]
		citizen.is_walking = data["is_walking"]

func time_loop():
	for citizen in get_children():
		citizen.time_loop()
