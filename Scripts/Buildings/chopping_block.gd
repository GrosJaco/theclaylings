extends CraftingBuilding
class_name ChoppingBlock

enum SpriteState { EMPTY, LOG, PLANKS }

@export_group("Visuals")
@export var empty_sprite: Texture2D
@export var log_sprite: Texture2D
@export var planks_sprite: Texture2D

@export_group("Limits")
@export var max_input: int = 1
@export var max_output: int = 2

var _current_state: SpriteState = SpriteState.EMPTY
var _base_root_y: float = 0.0


func _ready():
	super._ready()
	if sprite_root:
		_base_root_y = sprite_root.position.y
	_update_sprite()


func receive_item(item: ItemData, amount: int):
	var current = input_inventory.get(item, 0)
	var space = max_input - current
	if space > 0:
		super.receive_item(item, min(amount, space))
	_update_sprite()


func _produce_output(recipe: RecipeData):
	var item = recipe.output_item
	var current = output_inventory.get(item, 0)
	var space = max(max_output - current, 0)
	if space > 0:
		output_inventory[item] = current + min(recipe.output_amount, space)


func get_needed_items() -> Dictionary:
	var needed = super.get_needed_items()

	# Block input deliveries while crafting (log is being processed on the block)
	if is_crafting:
		needed.clear()
		return needed

	# Block input deliveries if planks are waiting to be collected
	if not output_inventory.is_empty():
		needed.clear()
		return needed

	for item in needed.keys():
		var current = input_inventory.get(item, 0) + incoming_deliveries.get(item, 0)
		needed[item] = min(needed[item], max_input - current)

	# Block deliveries when output is full
	var out_count = 0
	for item in output_inventory:
		out_count += output_inventory[item]
	if out_count >= max_output:
		needed.clear()

	return needed


func take_output() -> Dictionary:
	var result = super.take_output()
	_update_sprite()
	return result


func _on_crafting_started():
	_update_sprite()


func _on_crafting_stopped():
	_update_sprite()


func _update_sprite():
	if is_preview or sprite == null:
		return

	var new_state := SpriteState.EMPTY
	if not output_inventory.is_empty():
		new_state = SpriteState.PLANKS
	elif not input_inventory.is_empty() or is_crafting:
		new_state = SpriteState.LOG

	if new_state == _current_state:
		return
	_current_state = new_state

	var texture: Texture2D
	match new_state:
		SpriteState.LOG:
			texture = log_sprite
		SpriteState.PLANKS:
			texture = planks_sprite
		_:
			texture = empty_sprite

	if texture and sprite is Sprite2D:
		sprite.texture = texture

	# Compensate Y offset: empty is 16x16, log/planks are 16x32
	if sprite_root and texture:
		var offset_y = (texture.get_height() - 16.0) * 0.5
		sprite_root.position.y = _base_root_y - offset_y
	elif sprite_root:
		sprite_root.position.y = _base_root_y
