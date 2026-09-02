extends Building
class_name BushBuilding

# ========== VARIABLES ==========

@export_group("Harvesting")
@export var harvest_group: String = "plants"
var is_marked_for_harvest: bool = false
var original_modulate: Color = Color.WHITE

@export_group("Resources")
@export var resource_item: ItemData
@export var min_drop: int = 1
@export var max_drop: int = 3

@export_group("Visual Variations")
@export var possible_sprites: Array[Texture2D] = []

# ========== FUNCTIONS ==========

func _ready():
	add_to_group(harvest_group) 
	super._ready()
	_apply_random_visuals()

func take_damage(amount: int):
	super.take_damage(amount)
	_play_squash_effect()

func destroyed():
	_drop_resources()
	super.destroyed()

# ---------- HARVEST SYSTEM ----------

func set_highlight(active: bool) -> void:
	if sprite:
		sprite.modulate = (original_modulate * 1.5) if active else original_modulate

# ---------- HELPERS ----------

func _apply_random_visuals():
	if possible_sprites.size() > 0:
		var random_tex = possible_sprites.pick_random()
		
		if sprite is Sprite2D:
			sprite.texture = random_tex
			sprite.flip_h = (randi() % 2 == 0)
			original_modulate = Color(randf_range(0.98, 1.02), randf_range(0.96, 1.04), randf_range(0.8, 1.0))
			sprite.modulate = original_modulate

func _play_squash_effect():
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "scale", Vector2(1.2, 0.7), 0.05)
		tween.tween_property(sprite, "scale", Vector2(0.9, 1.1), 0.05)
		tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.05)

func _drop_resources():
	if resource_item == null: return
	var amount = randi_range(min_drop, max_drop)
	var parent_node = get_parent()
	
	for i in range(amount):
		var item = load("res://Scenes/item.tscn").instantiate()
		item.data = resource_item
		item.quantity = 1
		var offset = Vector2(randf_range(-4, 4), randf_range(-4, 4))
		item.global_position = global_position + offset
		parent_node.call_deferred("add_child", item)
