extends Spatial

signal building_selected(building)
signal building_updated(building)

func get_building(building_id):
	for building in get_children():
		if building.building_id == building_id:
			return building
	return null

func get_buildings(building_type):
	var buildings = []
	for building in get_children():
		if building.building_type == building_type:
			buildings.push_back(building)
	return buildings

func get_nearest_building(position):
	var nearest_building = null
	var nearest_distance = 9999999
	for building in get_children():
		var distance = building.entrance_position.distance_to(position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_building = building
	return nearest_building
	
func assign_building_ids():
	var id = 0
	for building in get_children():
		building.bulding_id = id
		id += 1
	
func on_building_selected(building):
	emit_signal("building_selected", building)

func on_building_updated(building):
	emit_signal("building_updated", building)

func time_loop():
	assert(get_tree().is_network_server())
	for building in get_children():
		building.time_loop()
