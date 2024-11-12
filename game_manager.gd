extends Node


class_name game_manager


const COOLANT_ICON = preload("res://Systems/Engines/Assets/Coolant Icon.png")
const FUEL_ICON = preload("res://Systems/Engines/Assets/Fuel Icon.png")

const PATCH_MODULE = preload("res://Systems/External/Assets/Patch module.png")
const SATELLITE_MODULE = preload("res://Systems/External/Assets/Satellite module.png")
const WIRE_MODULE = preload("res://Systems/External/Assets/Wire module.png")
const HEATER_MODULE = preload("res://Systems/External/Assets/Heater module.png")

const PATCH_MODULE_BLUEPRINT = preload("res://Systems/External/Assets/Patch module Blueprint.png")
const SATELLITE_MODULE_BLUEPRINT = preload("res://Systems/External/Assets/Satellite module Blueprint.png")
const WIRE_MODULE_BLUEPRINT = preload("res://Systems/External/Assets/Wire module Blueprint.png")
const HEATER_MODULE_BLUEPRINT = preload("res://Systems/External/Assets/Heater module Blueprint.png")

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

enum module_types {
	PATCH,
	SATELLITE,
	WIRE,
	HEATER
}


static func get_module_texture(module_type: module_types) -> CompressedTexture2D:
	match module_type:
		module_types.PATCH:
			return PATCH_MODULE
		module_types.SATELLITE:
			return SATELLITE_MODULE
		module_types.WIRE:
			return WIRE_MODULE
		module_types.HEATER:
			return HEATER_MODULE
	push_error("Could not find requested texture for a module")
	return Texture2D.new()


static func get_blueprint_texture(blueprint_type: module_types) -> CompressedTexture2D:
	match blueprint_type:
		module_types.PATCH:
			return PATCH_MODULE_BLUEPRINT
		module_types.SATELLITE:
			return SATELLITE_MODULE_BLUEPRINT
		module_types.WIRE:
			return WIRE_MODULE_BLUEPRINT
		module_types.HEATER:
			return HEATER_MODULE_BLUEPRINT
	push_error("Could not find requested texture for a module")
	return Texture2D.new()


static func get_random_cell_type() -> engine_cell_types:
	var types: Array[engine_cell_types] = [engine_cell_types.FUEL, engine_cell_types.COOLANT]
	return types[randi()%2]


static func get_random_hole_position() -> Vector2:
	return Vector2(randi_range(-272, 272), randi_range(-184, 128))
