class_name EnemySpawnData
extends Resource

@export var enemy_name: String = "Blue Spider"
@export var scene: PackedScene
@export var point_cost: int = 10 # Cost in budget points
@export var min_wave: int = 1 # Minimum wave before this enemy can spawn
@export var selection_weight: float = 1.0 # Probability bias (higher = picked more often)
