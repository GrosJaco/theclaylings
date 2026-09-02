extends Node
class_name State

# Reference back to the clayling using this state
var clayling

# Called when entering the state
func enter(msg := {}) -> void:
	pass

# Called when leaving the state
func exit() -> void:
	pass

# Called every frame while this state is active
func update(delta: float) -> void:
	pass
