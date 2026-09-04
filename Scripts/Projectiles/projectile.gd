extends Area2D
class_name Projectile

# ========== VARIABLES ==========

@export var speed: float = 130.0
@export var damage: float = 8.0
@export var max_lifetime: float = 3.0
@export var target_group: String = "claylings"

var direction: Vector2 = Vector2.RIGHT
var lifetime: float = 0.0
var shooter: Node2D = null

@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")

# ========== FUNCTIONS ==========

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1 | 2 # Layer 1: Entities, Layer 2: Walls & Buildings
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	lifetime += delta
	if lifetime >= max_lifetime:
		queue_free()
		return

	global_position += direction * speed * delta
	rotation = direction.angle()

func set_target_direction(dir: Vector2) -> void:
	direction = dir.normalized()
	rotation = direction.angle()

func _on_body_entered(body: Node2D) -> void:
	_handle_collision(body)

func _on_area_entered(area: Area2D) -> void:
	if not is_instance_valid(area):
		return
	var candidate = area.get_parent() if area.get_parent() else area
	_handle_collision(candidate)

func _handle_collision(node: Node2D) -> void:
	if not is_instance_valid(node) or node == shooter:
		return

	if node.get("is_dead"):
		return

	# Target group match (e.g. claylings)
	if target_group != "" and node.is_in_group(target_group):
		_on_hit(node)
		return

	# Central crystal & colony buildings
	if node.is_in_group("crystal") or node.is_in_group("central_crystal") or node is Building:
		_on_hit(node)
		return

	# Check if shot by enemy and hits a valid non-enemy damageable target
	if shooter and shooter.is_in_group("enemies"):
		if not node.is_in_group("enemies") and node.has_method("take_damage"):
			_on_hit(node)
			return

	# Check collision with walls (layer 2) only if not an entity
	if "collision_layer" in node and (node.collision_layer & 2) != 0:
		if not node.is_in_group("claylings") and not node.is_in_group("enemies"):
			_on_hit_wall(node)

func _on_hit(target: Node2D) -> void:
	if target is Building:
		target.take_damage(int(damage))
	elif target.has_method("take_damage"):
		target.take_damage(damage, shooter)
	queue_free()

func _on_hit_wall(_wall: Node2D) -> void:
	queue_free()
