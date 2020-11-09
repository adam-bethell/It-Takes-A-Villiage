extends Spatial

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
