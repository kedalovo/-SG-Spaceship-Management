extends Node


class_name game_manager


const COOLANT_ICON = preload("res://Systems/Engines/Assets/Coolant Icon.png")
const FUEL_ICON = preload("res://Systems/Engines/Assets/Fuel Icon.png")

const WIRE_COLORS: Array[Color] = [Color.RED, Color.BLUE, Color.YELLOW, Color.GREEN, Color.MAGENTA]

var is_in_system: bool = false


enum damage_types {
	PHYSICAL,
	HEAT,
	ELECTRICITY
}

enum engine_cell_types {
	NONE = -1,
	FUEL,
	COOLANT
}


static func get_random_cell_type() -> engine_cell_types:
	var types: Array[engine_cell_types] = [engine_cell_types.FUEL, engine_cell_types.COOLANT]
	return types[randi()%2]


static func get_random_hole_position() -> Vector2:
	return Vector2(randi_range(-272, 272), randi_range(-184, 128))
