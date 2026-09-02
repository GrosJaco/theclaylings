extends CraftingBuilding
class_name FurnaceBuilding

# ========== REFERENCES ==========

@onready var fire_particles = $FireParticles 
@onready var fire_light = $PointLight2D
@onready var smoke_particles = $SmokeParticles

# ========== FUNCTIONS ==========

func _ready():
	super._ready()
	_on_crafting_stopped()

# ---------- VISUAL HOOKS ----------

func _on_crafting_started():
	if fire_particles:
		fire_particles.emitting = true
		fire_particles.visible = true
	if fire_light:
		fire_light.enabled = true
	if smoke_particles:
		smoke_particles.emitting = true
		smoke_particles.visible = true
	start_ambient_sound()
	
func _on_crafting_stopped():
	if fire_particles:
		fire_particles.emitting = false
		fire_particles.visible = false
	if fire_light:
		fire_light.enabled = false
	if smoke_particles:
		smoke_particles.emitting = false
		smoke_particles.visible = false
	stop_ambient_sound()
