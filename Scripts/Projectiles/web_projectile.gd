extends Projectile
class_name WebProjectile

# ========== VARIABLES ==========

@export var slow_factor: float = 0.5
@export var slow_duration: float = 3.0

# ========== FUNCTIONS ==========

func _ready() -> void:
	super._ready()
	if animated_sprite and animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("fly"):
		animated_sprite.play("fly")

func _on_hit(target: Node2D) -> void:
	if not is_instance_valid(target):
		queue_free()
		return

	# Apply damage to buildings or entities
	if target is Building:
		target.take_damage(int(damage))
	elif target.has_method("take_damage"):
		target.take_damage(damage, shooter)

	# Apply web slow effect to entities that can be slowed
	if target.has_method("apply_slow"):
		target.apply_slow(slow_factor, slow_duration)

	queue_free()
