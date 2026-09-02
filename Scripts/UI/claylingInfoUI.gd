extends Control
class_name ClaylingInfoUI

# ========== REFERENCES ==========

@onready var portrait_rect: TextureRect = $Portrait
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var personality_label: Label = $VBoxContainer/PersonalityLabel
@onready var age_label: Label = $VBoxContainer/AgeLabel
@onready var health_bar: TextureProgressBar = $BarsContainer/HealthBar
@onready var energy_bar: TextureProgressBar = $BarsContainer/EnergyBar
@onready var hunger_bar: TextureProgressBar = $BarsContainer/HungerBar

# ========== VARIABLES ==========

@export var personality_portraits: Dictionary = {}
@export var default_portrait: Texture2D

var tracked_clayling: CharacterBody2D = null

# ========== FUNCTIONS ==========

func _ready():
	add_to_group("clayling_info_panel")
	visible = false
	
	portrait_rect.custom_minimum_size = Vector2(96, 96)
	portrait_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	_style_texture_bar(health_bar)
	_style_texture_bar(energy_bar)
	_style_texture_bar(hunger_bar)

func _process(_delta: float) -> void:
	if not visible: return
	if is_instance_valid(tracked_clayling):
		_refresh_bars()
	else:
		hide_panel()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		hide_panel()
		get_viewport().set_input_as_handled()

# ---------- PUBLIC API ----------

func show_clayling(clayling: CharacterBody2D) -> void:
	tracked_clayling = clayling
	
	portrait_rect.texture = personality_portraits.get(clayling.personality_trait, default_portrait)
	
	name_label.text = clayling.clayling_name 
	personality_label.text = clayling.personality_trait + "\n" + clayling.role.capitalize()
	age_label.text = str(clayling.age) + " y/o"
	
	_refresh_bars()
	visible = true

func open(clayling: CharacterBody2D) -> void:
	show_clayling(clayling)

func hide_panel() -> void:
	visible = false
	tracked_clayling = null

# ---------- INTERNAL ----------

func _refresh_bars() -> void:
	health_bar.max_value = tracked_clayling.max_health
	health_bar.value = tracked_clayling.health
	
	energy_bar.max_value = tracked_clayling.max_energy
	energy_bar.value = tracked_clayling.energy
	
	hunger_bar.max_value = tracked_clayling.max_hunger
	hunger_bar.value = tracked_clayling.hunger

func _style_texture_bar(bar: TextureProgressBar) -> void:
	bar.fill_mode = TextureProgressBar.FILL_BOTTOM_TO_TOP
	bar.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
