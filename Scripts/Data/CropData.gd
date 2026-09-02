extends TileCustomData
class_name CropData

@export var duration : float
@export var harvest_item: ItemData
@export var harvest_min: int = 1
@export var harvest_max: int = 1

# Get the growth index to know what tile to show depending on the growth level
func growth_index(time : float):
	var stage_index : int = int((time / duration) * (atlas_coords.size() - 1))
	return stage_index
