extends Resource
class_name RecipeData

# ========== VARIABLES ==========

@export_group("Inputs")
# Use the Inspector to add ItemData as Key, and the required amount (int) as Value
@export var inputs: Dictionary[ItemData, int] = {} 

@export_group("Output")
@export var output_item: ItemData
@export var output_amount: int = 1

@export_group("Settings")
@export var craft_time: float = 3.0
@export var need_clayling: bool = true
