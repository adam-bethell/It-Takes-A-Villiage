extends Spatial


const SPEED = 60.0
const ROTATION = 0.8
const ZOOM = 1
onready var camera = $Camera

#| Movement
func _process(delta):
	var dir = Vector3()
	
	# Boost
	var boost = 1.0
	if Input.is_action_pressed("camera_boost"):
		boost = 2.5
		
	# Movment
	if Input.is_action_pressed("camera_forward"):
		dir += -transform.basis.z
	if Input.is_action_pressed("camera_back"):
		dir += transform.basis.z
	if Input.is_action_pressed("camera_left"):
		dir += -transform.basis.x
	if Input.is_action_pressed("camera_right"):
		dir += transform.basis.x

	transform.origin += dir.normalized() * SPEED * boost * delta
	
	# Rotation
	var degrees = 0.0
	if Input.is_action_pressed("camera_rotate_clockwise"):
		degrees -= ROTATION
	if Input.is_action_pressed("camera_rotate_anticlockwise"):
		degrees += ROTATION
	
	transform.basis = transform.basis.rotated(Vector3.UP, degrees * delta * boost)
	
	# Zoom
	var zoom = 0.0
	if not get_tree().is_input_handled():
		if Input.is_action_pressed("camera_zoom_in") or Input.is_action_just_released("camera_zoom_in"):
			zoom -= ZOOM
		if Input.is_action_pressed("camera_zoom_out") or Input.is_action_just_released("camera_zoom_out"):
			zoom += ZOOM
	
	transform.origin = Vector3(
		transform.origin.x,
		clamp(transform.origin.y + zoom, 6, 120),
		transform.origin.z
	)
	
	
#| Raycasting
func _physics_process(delta):
	# It is only safe to get the space_state during _physics 
	if get_tree().is_input_handled():
		return
		
	if Input.is_action_just_pressed("mouse_select_1") or Input.is_action_just_pressed("mouse_select_2"):
		var walk = Input.is_action_just_pressed("mouse_select_1")
		var space_state = get_world().direct_space_state
		
		var mouse_position = get_viewport().get_mouse_position()
		var from = camera.project_ray_origin(mouse_position)
		var to = from + (camera.project_ray_normal(mouse_position) * 1000.0)
		
		var result = space_state.intersect_ray(from, to)
		if result.size() > 0:
			if result.collider.get_collision_layer() == 2:
				# Grass
				Globals.game_controller.set_player_citizen_destination(result.position, walk)
			elif result.collider.get_collision_layer() == 4: 
				# Building
				var building = result.collider.get_owner()
				building.selected()
				Globals.game_controller.set_player_citizen_destination(building.entrance_position, walk)

