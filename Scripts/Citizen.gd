tool
extends KinematicBody

signal citizen_updated()

# Mesh
export var mesh_name = "" setget set_mesh_by_name

# Nav
onready var nav = get_parent().get_parent()
onready var _previous_position = global_transform.origin

const WALK_SPEED = 4
const RUN_SPEED = 10
const ROTATION_SPEED = 3

var is_walking = true
var _rotation_amount = 0
var linear_velocity = Vector3.ZERO
var nav_path = []
var nav_path_index = 0

# Data
var player_id = -1
var owner_id = -1
var citizen_id = null
var start_position = Vector3.ZERO
var _inventory = []
	
	
#| Movement
func _physics_process(delta):
	if Engine.editor_hint:
		return
		
	# Movement
	if nav_path_index < nav_path.size():
		$DebugTarget.global_transform.origin = nav_path[-1]
		# Move
		var path_vec = nav_path[nav_path_index] - global_transform.origin
		var move_speed = WALK_SPEED if is_walking else RUN_SPEED
		var move_vec = path_vec.normalized() * move_speed
		
		# Rotate to face target
		var this_position = global_transform.origin
		var look_vector = (_previous_position - this_position) 
		look_vector.y = 0.0
		if look_vector.length() > 0.0:
			look_vector = look_vector.normalized() * 20
			var rot_transform = global_transform.looking_at(this_position + look_vector, Vector3.UP)
			var new_rotation = Quat(global_transform.basis).slerp(rot_transform.basis, _rotation_amount)
			_rotation_amount = clamp(_rotation_amount + (delta * ROTATION_SPEED), 0, 1)
			set_transform(Transform(new_rotation, global_transform.origin))
		_previous_position = this_position
		
		# Move toward target
		if path_vec.length() <= move_vec.length() * delta:
			_rotation_amount = 0.0
			nav_path_index += 1
				
		
		linear_velocity = move_and_slide(move_vec, Vector3.UP)
	else:
		# Not Moving
		linear_velocity = Vector3.ZERO


func set_destination(position, _is_walking):
	is_walking = _is_walking
	nav_path = nav.get_simple_path(global_transform.origin, position)
	nav_path_index = 0
	

#| Inventory
func equip_item(item):
	assert(get_tree().is_network_server())
	_inventory.push_back(item)
	if owner_id != -1:
		if owner_id == 1:
			emit_signal("citizen_updated")
		else:
			rpc_id(owner_id, "_rpc_update_inventory", _inventory)

func drop_item(item):
	assert(get_tree().is_network_server())
	_inventory.erase(item)
	if owner_id != -1:
		if owner_id == 1:
			emit_signal("citizen_updated")
		else:
			rpc_id(owner_id, "_rpc_update_inventory", _inventory)

remote func _rpc_update_inventory(inventory):
	_inventory = inventory
	emit_signal("citizen_updated")
	
func get_inventory():
	return _inventory
	
func has_item(item):
	return _inventory.has(item)
	
#| Mesh
func set_mesh_path(path):
	$Armature/Skeleton/Mesh.mesh = load(path)
	
func set_mesh_by_name(name):
	var path = "res://Models/Citizens/" + name + ".tres"
	# Only ignore invalid paths in the editor 
	if Engine.editor_hint and not ResourceLoader.exists(path):
		return
	$Armature/Skeleton/Mesh.mesh = load(path)

#| Time Loop
func time_loop():
	is_walking = true
	_rotation_amount = 0
	linear_velocity = Vector3.ZERO
	nav_path = []
	nav_path_index = 0
	global_transform.origin = start_position
	player_id = -1
	
	_inventory = []
	if owner_id != -1:
		if owner_id == 1:
			emit_signal("citizen_updated")
		else:
			rpc_id(owner_id, "_rpc_time_loop")
			rpc_id(owner_id, "_rpc_update_inventory", _inventory)
	
remote func _rpc_time_loop():
	player_id = -1
