extends Building
class_name Sapling

# ========== VARIABLES ==========

@export_group("Growth")
@export var grow_time: float = 5.0
@export var adult_tree_scene: PackedScene

@export_group("Visual Variations")
@export var possible_sprites: Array[Texture2D] = []

var current_timer: float = 0.0
var is_growing: bool = true

# ========== FUNCTIONS ==========

func _ready():
	super._ready()
	add_to_group("saplings")
	
	current_timer = grow_time + randf_range(-1.0, 1.0)
	
	_apply_random_visuals()

func _apply_random_visuals():
	if possible_sprites.size() > 0:
		var random_tex = possible_sprites.pick_random()
		
		if sprite and sprite is Sprite2D:
			sprite.texture = random_tex
			sprite.flip_h = (randi() % 2 == 0) 
			sprite.modulate = Color(randf_range(0.8, 1.0), randf_range(0.8, 1.0), randf_range(0.8, 1.0))

func _process(delta: float):
	if is_preview:
		return
	
	if !is_growing:
		return
		
	current_timer -= delta
	
	if current_timer <= 0:
		grow_into_tree()

func grow_into_tree():
	if is_preview: 
		return

	is_growing = false
	
	if adult_tree_scene:
		var tree = adult_tree_scene.instantiate()
		tree.global_position = global_position
		get_parent().add_child(tree)
		queue_free()
