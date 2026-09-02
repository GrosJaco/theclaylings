extends AnimalState

var threat_node: Node = null
@export var flee_speed_multiplier := 1.5

func enter(msg := {}):
	# Assign the threat from message
	threat_node = msg.get("threat", null)
	animal.sprite.play("run")

func update(delta: float):
	# If threat no longer exists, calm down
	if not is_instance_valid(threat_node):
		animal.change_state("Idle")
		return

	# Run away from the threat
	var dir = (animal.global_position - threat_node.global_position).normalized()
	animal.velocity = dir * animal.speed * flee_speed_multiplier

	# Small chance each frame to calm down
	if randi() % 100 < 2:
		animal.change_state("Idle")

func exit():
	animal.velocity = Vector2.ZERO
