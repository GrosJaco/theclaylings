extends Node2D
class_name WorldItem

@export var data: ItemData : set = set_data
@export var quantity: int = 1 : set = set_quantity

@onready var sprite: Sprite2D = $Sprite2D
@onready var area: Area2D = $Area2D

func _ready() -> void:
	add_to_group("ground_items")
	_refresh()

# When a clayling enters Area2D
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.world.find_nearest_storage_with_space(body.global_position) == null:
		return
	if !body.has_method("pick_item"):
		return
	if data == null or quantity <= 0:
		return
	
	# Check if there is a storage
	if body.world.find_nearest_storage_with_space(body.global_position) == null:
		return
	
	var taken: int = body.pick_item(data, quantity)
	if taken <= 0:
		return
	
	quantity -= taken
	if quantity <= 0:
		queue_free()
	else:
		_refresh()

# Update data
func set_data(v: ItemData) -> void:
	data = v
	_refresh()

func set_quantity(v: int) -> void:
	if !data:
		quantity = v
	else:
		quantity = clamp(v, 0, data.stack_size)
	_refresh()

func _refresh() -> void:
	if !is_inside_tree():
		return
	if data and sprite:
		sprite.texture = data.icon

func can_stack_with(other: WorldItem) -> bool:
	return other and other.data == data and data != null and data.stack_size > 1

# Add a quantity and return what couldn't be added
func add_quantity(amount: int) -> int:
	if !data:
		return amount
	var room = data.stack_size - quantity
	var taken = min(amount, room)
	quantity += taken
	_refresh()
	return amount - taken
