extends Resource


class_name save_game_template


@export var consumables: Dictionary = {}
@export var life_support_tier: int = 0
@export var engines_tier: int = 0
@export var hull_tier: int = 0
@export var is_ballistic: bool = false
@export var can_control_via_arrows: bool = false
@export var scan_distance: int = 0

@export var algae_amount: int = 0
@export var fuel_cell_amount: int = 0
@export var coolant_cell_amount: int = 0
@export var patch_amount: int = 0

@export var consumed_algae: Array[float] = []
@export var consumed_fuel_cells: Array[float] = []
@export var consumed_coolant_cells: Array[float] = []

@export var map_data: Array = []
@export var balance: int = 0
@export var map_path: Array[Vector2i] = []
@export var current_location_index: Vector2i = Vector2i(0, 0)
