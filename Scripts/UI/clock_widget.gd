extends Control
class_name ClockWidget

@onready var arrow: TextureRect = $Arrow
@onready var time_label: Label = $TimeLabel
@onready var day_label: Label = $DayLabel

@export var sun_angle: float = -90
@export var moon_angle: float = 90

var _day_night: Node = null

func _process(_delta: float) -> void:
	var cycle = _get_day_night()
	if cycle == null:
		return
	
	var swing = abs(cycle.time_of_day - 0.5) * 2.0
	arrow.rotation_degrees = lerp(sun_angle, moon_angle, swing)
	
	time_label.text = _format_time(cycle.get_hour())
	day_label.text = DayNightCycle.to_roman(cycle.current_day)

func _get_day_night() -> Node:
	if _day_night == null or not is_instance_valid(_day_night):
		_day_night = get_tree().get_first_node_in_group("day_night_cycle")
	return _day_night

func _format_time(hour_float: float) -> String:
	var total_minutes = int(hour_float * 60.0)
	var h = total_minutes / 60
	var m = total_minutes % 60
	return "%02d:%02d" % [h, m]
