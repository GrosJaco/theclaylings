extends Node2D
class_name Building
@onready var sprite_root: Node2D = $SpriteRoot
@onready var sprite: Node2D = $SpriteRoot.get_child(0) # Sprite2D or AnimatedSprite2D
var is_preview: bool = false
@export var building_type: String
@export var size_in_tiles: Vector2i = Vector2i(1,1)
@export var max_health: int = 100
var current_health: int

@export_group("Ambient Sound")
@export var ambient_sounds: Array[String] = []
@export var ambient_interval_min: float = 3.0
@export var ambient_interval_max: float = 8.0

var _ambient_timer: Timer = null

func _ready():
	current_health = max_health
	update_sprite()
	
	_ambient_timer = Timer.new()
	_ambient_timer.one_shot = true
	_ambient_timer.timeout.connect(_on_ambient_timeout)
	add_child(_ambient_timer)
	self.y_sort_enabled = true

func interact(clayling):
	pass
func update_sprite():
	if sprite is Sprite2D:
		sprite.frame = 0 # Can also change texture
	elif sprite is AnimatedSprite2D:
		sprite.play("filled")
func take_damage(amount: int):
	current_health = max(current_health - amount, 0)
	update_sprite()
	if current_health <= 0:
		destroyed()

func destroyed():
	var manager = get_tree().get_first_node_in_group("building_manager")
	if manager:
		var occupied_tiles: Array[Vector2i] = []
		var offset = Vector2((size_in_tiles.x * 16) / 2.0, size_in_tiles.y * 16)
		var top_left_world_pos = global_position - offset
		var top_left_tile = Vector2i(
			round(top_left_world_pos.x / 16.0),
			round(top_left_world_pos.y / 16.0)
		)
		for x in range(size_in_tiles.x):
			for y in range(size_in_tiles.y):
				occupied_tiles.append(top_left_tile + Vector2i(x, y))
		manager.free_tiles(occupied_tiles)
		
	queue_free()

# ---------- AMBIENT SOUND ----------

func start_ambient_sound() -> void:
	if is_preview or ambient_sounds.is_empty():
		return
	_queue_next_ambient_sound()

func stop_ambient_sound() -> void:
	_ambient_timer.stop()

func _queue_next_ambient_sound() -> void:
	_ambient_timer.start(randf_range(ambient_interval_min, ambient_interval_max))

func _on_ambient_timeout() -> void:
	if is_preview or ambient_sounds.is_empty():
		return
	var sound_name = ambient_sounds[randi() % ambient_sounds.size()]
	SoundManager.play_at(sound_name, global_position)
	_queue_next_ambient_sound()
	
