extends AnimalState

@export var wander_radius := 64

func enter(msg := {}) -> void:
	var target_pos = animal.global_position + Vector2(randf_range(-wander_radius, wander_radius), randf_range(-wander_radius, wander_radius))
	while animal.world.building_manager.used_tiles.has(animal.world.get_grid_position(target_pos)):
		target_pos = animal.global_position + Vector2(randf_range(-wander_radius, wander_radius), randf_range(-wander_radius, wander_radius))
	animal.move_to(target_pos)
	animal.sprite.play("run")

func update(delta: float) -> void:
	# If there is a threat, flee immediately
	if animal.threat:
		animal.change_state("Flee", {"threat": animal.threat})
		return
	
	# Check if the animal reached the target
	if animal.global_position.distance_to(animal.agent.target_position) < 10.0:
		animal.velocity = Vector2.ZERO
		animal.change_state("Idle")
