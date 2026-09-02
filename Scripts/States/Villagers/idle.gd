extends State

# How long the clayling stays idle before doing something else
@export var idle_time = 5
var timer = 0.0

func enter(msg := {}) -> void:
	clayling.stop_moving()
	
	# If carrying items but no storage is available, drop everything
	if !clayling.is_inventory_empty():
		var nearest_storage = clayling.world.find_nearest_storage_with_space(clayling.global_position)
		if nearest_storage:
			clayling.change_state("Haul", {"storage": nearest_storage})
			return
		else:
			# No storage, then drop items and stay idle
			clayling.drop_item(-1, true)
			return

	timer = randi_range(idle_time - 1, idle_time + 1)

func update(delta: float) -> void:
	if _try_pickup_nearby():
		return
	timer -= delta
	if timer <= 0.0:
		clayling.change_state("Wander")

func _try_pickup_nearby() -> bool:
	if !clayling.is_inventory_empty():
		return false

	var nearest = null
	var best_dist = INF
	for n in clayling.get_tree().get_nodes_in_group("ground_items"):
		if n == null or !is_instance_valid(n):
			continue
		if clayling._carry_capacity_for(n.data) <= 0:
			continue
		var dist = clayling.global_position.distance_to(n.global_position)
		if dist < 250.0 and dist < best_dist:
			nearest = n
			best_dist = dist

	if nearest and clayling.world.find_nearest_storage_with_space(clayling.global_position):
		if clayling.world.reserve_pickup(nearest, clayling):
			clayling.change_state("Pick up", {"node": nearest})
			return true
	return false
