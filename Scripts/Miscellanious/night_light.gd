extends PointLight2D
class_name NightLight

@export var night_energy: float = 0.6
@export var fade_duration: float = 2.0

var _connected: bool = false
var _tween: Tween = null

func _ready() -> void:
	energy = 0.0

func _process(_delta: float) -> void:
	if _connected:
		return
	var cycle = get_tree().get_first_node_in_group("day_night_cycle")
	if cycle:
		energy = night_energy if cycle.is_night() else 0.0
		cycle.night_started.connect(func(): _fade_to(night_energy))
		cycle.day_started.connect(func(): _fade_to(0.0))
		_connected = true

func _fade_to(target_energy: float) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "energy", target_energy, fade_duration)
