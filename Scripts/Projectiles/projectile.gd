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
	collision_mask = 1 | 2 # Layer 1: Entities, Layer 2: Walls
	body_entered.connect(_on_body_entered)

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
	if not is_instance_valid(body) or body == shooter:
		return

	# Check collision with valid targets first
	if target_group != "" and body.is_in_group(target_group):
		if body.get("is_dead"):
			return
		_on_hit(body)
		return

	# Check collision with walls (layer 2) only if not an entity
	if "collision_layer" in body and (body.collision_layer & 2) != 0:
		if not body.is_in_group("claylings") and not body.is_in_group("enemies"):
			_on_hit_wall(body)

func _on_hit(target: Node2D) -> void:
	if target.has_method("take_damage"):
		target.take_damage(damage, shooter)
	queue_free()

func _on_hit_wall(_wall: Node2D) -> void:
	queue_free()
