extends Node2D

# ========== REFERENCES ==========

@onready var world: Node2D = $".."
@export var blueprint_scene: PackedScene

# ========== VARIABLES ==========

const TILE := 16

var used_tiles: Array[Vector2i] = []

var preview_instance: Node2D = null
var current_preview_scene: PackedScene = null
var is_previewing := false

var preview_tiles: Array[Vector2i] = []
var preview_can_place := false

var current_build_cost: Dictionary = {}
var current_build_texture: Texture2D = null

# ---------- BUILDINGS ----------

@export var soil_tile_scene: PackedScene = preload("res://Scenes/Buildings/SoilTile.tscn")

var storage_building_scene: PackedScene = preload("res://Scenes/Buildings/StorageBuilding.tscn")
var weapon_rack_scene: PackedScene = preload("res://Scenes/Buildings/WeaponRack.tscn")
var furnace_scene: PackedScene = preload("res://Scenes/Buildings/Furnace.tscn")
var forge_scene: PackedScene = preload("res://Scenes/Buildings/Forge.tscn")


@export var sapling_scene: PackedScene = preload("res://Scenes/Buildings/OakSapling.tscn")


# ========== FUNCTIONS ==========

func _ready() -> void:
	add_to_group("building_manager")

# ---------- INPUT ----------

func _input(event):
	# Key bindings for building selection
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_A:
			start_preview(storage_building_scene)
		if event.keycode == KEY_B:
			start_preview(soil_tile_scene)
		if event.keycode == KEY_F:
			start_preview(furnace_scene)
		if event.keycode == KEY_O:
			start_preview(forge_scene)
		if event.keycode == KEY_W:
			if weapon_rack_scene:
				start_preview(weapon_rack_scene)
		if event.keycode == KEY_T:
			if sapling_scene:
				start_preview(sapling_scene)
	
	# Mouse interaction during preview
	if is_previewing and event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var b_type = preview_instance.get("building_type")
			if b_type == null:
				b_type = "building"
			if b_type == "ground_tile":
				place_tile_type(b_type)
			else:
				confirm_placement()
				get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			cancel_preview()
			get_viewport().set_input_as_handled()

# ---------- PREVIEW ----------

func start_preview(scene: PackedScene, cost: Dictionary = {}):
	cancel_preview()
	current_preview_scene = scene
	current_build_cost = cost
	preview_instance = scene.instantiate()
	add_child(preview_instance)
	preview_instance.modulate = Color(1, 1, 1, 0.5)
	
	if "is_preview" in preview_instance:
		preview_instance.is_preview = true
		
	is_previewing = true

func _process(_delta):
	if !is_previewing or !preview_instance:
		return
	_update_preview_under_mouse()

func _update_preview_under_mouse():
	var size: Vector2i = Vector2i(1, 1)

	var s = preview_instance.get("size_in_tiles")
	if s != null:
		size = s
		
	var mouse_pos = get_global_mouse_position()
	var half_size_pixels = Vector2(size.x * TILE, size.y * TILE) / 2.0
	var raw_top_left = mouse_pos - half_size_pixels
	
	var top_left_tile := Vector2i(
		floor((raw_top_left.x / TILE) + 0.5),
		floor((raw_top_left.y / TILE) + 0.5)
	)
	
	var top_left_world_pos := Vector2(top_left_tile) * TILE
	
	var offset = Vector2( (size.x * TILE) / 2.0, size.y * TILE )
	preview_instance.global_position = top_left_world_pos + offset

	preview_tiles.clear()
	for x in range(size.x):
		for y in range(size.y):
			preview_tiles.append(top_left_tile + Vector2i(x, y))
	
	preview_can_place = true
	for t in preview_tiles:
		if t in used_tiles:
			preview_can_place = false
			break
	
	preview_instance.modulate = (Color(0, 1, 0, 0.5) if preview_can_place else Color(1, 0, 0, 0.5))

# ---------- PLACEMENT ----------

func place_tile_type(x):
	if world == null:
		cancel_preview()
		return

	match x:
		"ground_tile":
			for tile in preview_tiles:
				world.ground.set_cell(tile, 0, Vector2i(6,0))
				world.water_level[tile] = 0
				used_tiles.append(tile)
	
	cancel_preview()

func confirm_placement():
	if !is_previewing or !preview_instance:
		return
	_update_preview_under_mouse()
	if !preview_can_place:
		return

	var spawn_position = preview_instance.global_position
	var is_blueprint = not current_build_cost.is_empty()
	var placed: Node2D

	if is_blueprint:
		if not blueprint_scene:
			cancel_preview()
			return
		placed = blueprint_scene.instantiate()
	else:
		placed = current_preview_scene.instantiate()

	placed.global_position = spawn_position

	if world:
		world.add_child(placed)
	else:
		add_child(placed)

	if is_blueprint:
		placed.setup(current_preview_scene, current_build_cost)
	else:
		placed.modulate = Color(1, 1, 1, 1)
		if "is_preview" in placed:
			placed.is_preview = false

	for t in preview_tiles:
		if t not in used_tiles:
			used_tiles.append(t)

	cancel_preview()

func cancel_preview():
	if preview_instance:
		preview_instance.queue_free()
	preview_instance = null
	current_preview_scene = null
	current_build_cost = {}
	is_previewing = false
	preview_tiles.clear()
	preview_can_place = false

#---------- DELETING ----------

func free_tiles(tiles_to_free: Array[Vector2i]) -> void:
	for tile in tiles_to_free:
		used_tiles.erase(tile)
