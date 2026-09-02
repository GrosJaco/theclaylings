extends Node2D
class_name Blueprint

# ========== VARIABLES ==========

var target_building_scene: PackedScene
var required_materials: Dictionary = {}
var current_materials: Dictionary = {}
var incoming_deliveries: Dictionary = {}
var is_preview: bool = false 
@onready var visual_root: Node2D = $VisualRoot

# ========== FUNCTIONS ==========

func setup(scene: PackedScene, materials: Dictionary):
	target_building_scene = scene
	required_materials = materials
	_setup_visual(scene)

func _setup_visual(scene: PackedScene) -> void:
	for child in visual_root.get_children():
		child.queue_free()
	
	if not scene:
		return
	
	var temp: Node = scene.instantiate()
	var source_sprite_root: Node = temp.get_node_or_null("SpriteRoot")
	
	if source_sprite_root:
		temp.remove_child(source_sprite_root)
		visual_root.add_child(source_sprite_root)
		source_sprite_root.modulate = Color(0.2, 0.6, 0.8, 0.5)
		
		var visual = source_sprite_root.get_child(0)
		if visual is AnimatedSprite2D and visual.sprite_frames and visual.sprite_frames.has_animation("filled"):
			visual.play("filled")
	
	temp.queue_free()

func _ready():
	add_to_group("crafting_buildings")
	current_materials = {}
	incoming_deliveries = {}
	
# ---------- LOGISTIC ----------

func get_needed_items() -> Dictionary:
	var needed = {}
	for item in required_materials:
		var current = current_materials.get(item, 0) + incoming_deliveries.get(item, 0)
		var target = required_materials[item]
		if current < target:
			needed[item] = target - current
	return needed

func receive_item(item: ItemData, amount: int):
	if incoming_deliveries.has(item):
		incoming_deliveries[item] -= amount
		if incoming_deliveries[item] <= 0:
			incoming_deliveries.erase(item)
	current_materials[item] = current_materials.get(item, 0) + amount
	_check_completion()

func cancel_delivery(item: ItemData, amount: int):
	if incoming_deliveries.has(item):
		incoming_deliveries[item] -= amount
		if incoming_deliveries[item] <= 0:
			incoming_deliveries.erase(item)

# ---------- CONSTRUCTION ----------

func _check_completion():
	for item in required_materials:
		if current_materials.get(item, 0) < required_materials[item]:
			return
	_build()

func _build():
	if target_building_scene:
		var real_building = target_building_scene.instantiate()
		real_building.global_position = global_position
		get_parent().add_child(real_building)
		queue_free()
