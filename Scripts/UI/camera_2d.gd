extends Camera2D

@export var zoom_speed: float = 0.25 
@export var zoom_min: float = 0.5
@export var zoom_max: float = 4.0 # Update sound_manager if changed
@export var smooth_factor: float = 10.0

@export var keyboard_pan_speed: float = 600.0

var target_zoom: float = 1.0
var dragging: bool = false

func _ready():
	target_zoom = zoom.x

func _process(delta: float):
	zoom = zoom.lerp(Vector2(target_zoom, target_zoom), smooth_factor * delta)
	
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direction != Vector2.ZERO:
		position += direction * keyboard_pan_speed * delta / zoom.x

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			dragging = event.pressed

	elif event is InputEventMouseMotion and dragging:
		position -= event.relative / zoom.x

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			target_zoom += zoom_speed
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			target_zoom -= zoom_speed
			
		target_zoom = clamp(target_zoom, zoom_min, zoom_max)
