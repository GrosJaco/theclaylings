extends AnimalState

var timer := 0.0

func enter(msg := {}):
	timer = randf_range(animal.idle_time_min, animal.idle_time_max)
	# Pick an animation (idle/eat)
	if randf() < 0.75:
		animal.sprite.play("idle")
	else:
		animal.sprite.play("eat")

	# Stop moving
	animal.velocity = Vector2.ZERO

func update(delta: float):
	# If a threat is present, immediately flee
	if animal.threat:
		animal.change_state("Flee", {"threat": animal.threat})
		return

	# Countdown timer
	timer -= delta
	if timer <= 0:
		animal.change_state("Wander")

func exit():
	# Reset velocity when leaving state
	animal.velocity = Vector2.ZERO
