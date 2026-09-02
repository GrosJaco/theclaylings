extends Label
class_name DayBanner

var _day_night: Node = null
var _connected: bool = false

func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pivot_offset = size / 2.0

func _process(_delta: float) -> void:
	if _connected:
		return
	var cycle = _get_day_night()
	if cycle:
		cycle.new_day_announced.connect(_on_new_day_announced)
		_connected = true

func _get_day_night() -> Node:
	if _day_night == null or not is_instance_valid(_day_night):
		_day_night = get_tree().get_first_node_in_group("day_night_cycle")
	return _day_night

func _on_new_day_announced(day_number: int) -> void:
	text = DayNightCycle.to_roman(day_number)
	modulate.a = 0.0
	scale = Vector2(0.8, 0.8)
	visible = true
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.6)
	tween.parallel().tween_property(self, "scale", Vector2(1.0, 1.0), 0.6)
	tween.tween_interval(2.0)
	tween.tween_property(self, "modulate:a", 0.0, 0.6)
	tween.tween_callback(func(): visible = false)
