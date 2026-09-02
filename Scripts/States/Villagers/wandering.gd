extends State

# How far from its current position the clayling will move
var wander_radius = 75
func enter(msg := {}) -> void:
	var target_pos = clayling.global_position + Vector2(randf_range(-wander_radius, wander_radius), randf_range(-wander_radius, wander_radius))
	while target_pos == null or clayling.world.building_manager.used_tiles.has(clayling.world.get_grid_position(target_pos)):
		target_pos = clayling.global_position + Vector2(randf_range(-wander_radius, wander_radius), randf_range(-wander_radius, wander_radius))
	clayling.move_to(target_pos)

func update(delta: float) -> void:
	if clayling.global_position.distance_to(clayling.agent.target_position) < 8.0:
		clayling.velocity = Vector2.ZERO
		clayling.change_state("Idle")
