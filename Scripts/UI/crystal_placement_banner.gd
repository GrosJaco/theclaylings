extends Control
class_name CrystalPlacementBanner

# ========== FUNCTIONS ==========

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	call_deferred("_connect_building_manager")

func _connect_building_manager() -> void:
	var manager = get_tree().get_first_node_in_group("building_manager")
	if manager and manager.has_signal("initial_crystal_placed"):
		manager.initial_crystal_placed.connect(_on_crystal_placed)

func _on_crystal_placed(_crystal: Node2D) -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.6)
	tween.tween_callback(queue_free)
