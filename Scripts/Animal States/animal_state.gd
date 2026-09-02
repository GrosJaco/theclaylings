extends Node
class_name AnimalState

var animal: Animal

func _init(a: Animal = null):
	animal = a

func enter(msg := {}): pass
func update(delta: float): pass
func exit(): pass
