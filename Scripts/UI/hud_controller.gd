extends CanvasLayer
class_name HUDController

# ========== REFERENCES ==========

@onready var inventory_ui: Control = $InventoryUI
@onready var clock_widget: Control = $ClockWidget
@onready var time_speed_ui: Control = $TimeSpeedUI
@onready var build_menu: Control = $BuildMenu
@onready var task_priority_menu: Control = $TaskPriorityMenu
@onready var clayling_info_ui: Control = $ClaylingInfoUI
@onready var defeat_ui: DefeatUI = $DefeatUI

var _gameplay_hud_elements: Array[Control] = []
var _is_hud_visible: bool = true

# ========== FUNCTIONS ==========

func _ready() -> void:
	add_to_group("hud_controller")

	_gameplay_hud_elements = [
		inventory_ui,
		clock_widget,
		time_speed_ui,
		build_menu,
		task_priority_menu
	]

	# Hide HUD if waiting for initial crystal placement
	var has_crystal = _has_active_crystal()
	if not has_crystal:
		set_gameplay_hud_visible(false)

	call_deferred("_connect_signals")

func _has_active_crystal() -> bool:
	var crystals = get_tree().get_nodes_in_group("crystal")
	for c in crystals:
		if is_instance_valid(c) and not c.get("is_preview"):
			return true
	return false

func _connect_signals() -> void:
	var building_manager = get_tree().get_first_node_in_group("building_manager")
	if building_manager and building_manager.has_signal("initial_crystal_placed"):
		building_manager.initial_crystal_placed.connect(_on_initial_crystal_placed)

	if defeat_ui and defeat_ui.has_signal("defeat_shown"):
		defeat_ui.defeat_shown.connect(_on_defeat)

	var crystals = get_tree().get_nodes_in_group("crystal")
	for c in crystals:
		_connect_crystal_events(c)

func _connect_crystal_events(crystal_node: Node2D) -> void:
	if crystal_node and is_instance_valid(crystal_node) and not crystal_node.get("is_preview"):
		if crystal_node.has_signal("crystal_destroyed"):
			if not crystal_node.crystal_destroyed.is_connected(_on_defeat):
				crystal_node.crystal_destroyed.connect(_on_defeat)

func _on_initial_crystal_placed(crystal_node: Node2D) -> void:
	_connect_crystal_events(crystal_node)
	set_gameplay_hud_visible(true, true)

func _on_defeat() -> void:
	set_gameplay_hud_visible(false, false)
	if clayling_info_ui and is_instance_valid(clayling_info_ui):
		clayling_info_ui.visible = false

	var radial_menu = get_tree().get_first_node_in_group("radial_menu")
	if radial_menu and radial_menu.has_method("hide"):
		radial_menu.hide()

func set_gameplay_hud_visible(is_vis: bool, animate: bool = false) -> void:
	_is_hud_visible = is_vis

	for elem in _gameplay_hud_elements:
		if not elem or not is_instance_valid(elem):
			continue

		if is_vis:
			elem.visible = true
			if animate:
				elem.modulate.a = 0.0
				var tween = create_tween()
				tween.tween_property(elem, "modulate:a", 1.0, 0.4)
			else:
				elem.modulate.a = 1.0
		else:
			elem.visible = false
			elem.modulate.a = 1.0

	if not is_vis and clayling_info_ui and is_instance_valid(clayling_info_ui):
		clayling_info_ui.visible = false
