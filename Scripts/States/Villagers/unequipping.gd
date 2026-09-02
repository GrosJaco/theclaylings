extends State

# ========== VARIABLES ==========

var target_rack: Node2D = null

# ========== FUNCTIONS ==========

func enter(msg: Dictionary = {}) -> void:
	target_rack = msg.get("target_rack", null)
	clayling.force_animation = ""

	if target_rack and is_instance_valid(target_rack):
		var dest = target_rack.global_position
		if "interaction_point" in target_rack and target_rack.interaction_point:
			dest = target_rack.interaction_point.global_position
		clayling.move_to(dest)
	else:
		_abort_unequip()

func exit() -> void:
	if target_rack and is_instance_valid(target_rack) and target_rack.has_method("release_unequip_reservation"):
		target_rack.release_unequip_reservation(clayling)
	target_rack = null

func update(_delta: float) -> void:
	if not is_instance_valid(target_rack):
		_abort_unequip()
		return

	var dest = target_rack.global_position
	if "interaction_point" in target_rack and target_rack.interaction_point:
		dest = target_rack.interaction_point.global_position

	var dist_sq = clayling.global_position.distance_squared_to(dest)
	if clayling.agent.is_navigation_finished() or dist_sq <= 36.0:
		_on_arrival()

func _on_arrival() -> void:
	if target_rack and is_instance_valid(target_rack):
		var success = clayling.unequip_at_rack(target_rack)
		if not success:
			_abort_unequip()
	else:
		_abort_unequip()

func _abort_unequip() -> void:
	clayling.stop_moving()
	if clayling.role == "spearman":
		clayling.change_state("SoldierToStance")
	elif clayling.role == "archer" or clayling.role == "knight":
		clayling.change_state("SoldierIdle")
	else:
		clayling.change_state("Idle")

