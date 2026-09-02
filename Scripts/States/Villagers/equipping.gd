extends State

# ========== VARIABLES ==========

var target_rack: Node2D = null

# ========== FUNCTIONS ==========

func enter(msg: Dictionary = {}) -> void:
	if msg.has("target"):
		target_rack = msg["target"]
		var dest = target_rack.global_position
		if "interaction_point" in target_rack and target_rack.interaction_point:
			dest = target_rack.interaction_point.global_position
		clayling.move_to(dest)
	else:
		clayling.change_state("Idle")

func exit() -> void:
	if target_rack and is_instance_valid(target_rack) and target_rack.has_method("release_equip_reservation"):
		target_rack.release_equip_reservation(clayling)
	target_rack = null

func update(_delta: float) -> void:
	if not is_instance_valid(target_rack):
		clayling.change_state("Idle")
		return

	var dest = target_rack.global_position
	if "interaction_point" in target_rack and target_rack.interaction_point:
		dest = target_rack.interaction_point.global_position

	var dist_sq = clayling.global_position.distance_squared_to(dest)
	if clayling.agent.is_navigation_finished() or dist_sq <= 36.0:
		_on_arrival()

func _on_arrival() -> void:
	var success = clayling.try_equip_from_rack(target_rack)
	if not success:
		clayling.change_state("Idle")

