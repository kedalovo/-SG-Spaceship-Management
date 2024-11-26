extends Node


class_name game_manager


const COOLANT_ICON = preload("res://Systems/Engines/Assets/Coolant Icon.png")
const FUEL_ICON = preload("res://Systems/Engines/Assets/Fuel Icon.png")

const PATCH_MODULE = preload("res://Systems/External/Assets/Patch module.png")
const SATELLITE_MODULE = preload("res://Systems/External/Assets/Satellite module.png")
const WIRE_MODULE = preload("res://Systems/External/Assets/Wire module.png")
const HEATER_MODULE = preload("res://Systems/External/Assets/Heater module.png")

const PATCH_MODULE_OUTLINE = preload("res://Systems/External/Assets/Patch module Outline.png")
const SATELLITE_MODULE_OUTLINE = preload("res://Systems/External/Assets/Satellite module Outline.png")
const WIRE_MODULE_OUTLINE = preload("res://Systems/External/Assets/Wire module Outline.png")
const HEATER_MODULE_OUTLINE = preload("res://Systems/External/Assets/Heater module Outline.png")

const PATCH_MODULE_BLUEPRINT = preload("res://Systems/External/Assets/Patch module Blueprint.png")
const SATELLITE_MODULE_BLUEPRINT = preload("res://Systems/External/Assets/Satellite module Blueprint.png")
const WIRE_MODULE_BLUEPRINT = preload("res://Systems/External/Assets/Wire module Blueprint.png")
const HEATER_MODULE_BLUEPRINT = preload("res://Systems/External/Assets/Heater module Blueprint.png")

const LARGE_ASTEROID = preload("res://Hazards/Asteroid/Assets/Large asteroid.png")
const MEDIUM_ASTEROID = preload("res://Hazards/Asteroid/Assets/Medium asteroid.png")
const SMALL_ASTEROID = preload("res://Hazards/Asteroid/Assets/Small asteroid.png")

const WIRE_COLORS: Array[Color] = [Color.RED, Color.BLUE, Color.YELLOW, Color.GREEN, Color.MAGENTA]

static var is_in_system: bool = false


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

enum asteroid_types {
	SMALL,
	MEDIUM,
	LARGE
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


static func get_module_outline_texture(module_type: module_types) -> CompressedTexture2D:
	match module_type:
		module_types.PATCH:
			return PATCH_MODULE_OUTLINE
		module_types.SATELLITE:
			return SATELLITE_MODULE_OUTLINE
		module_types.WIRE:
			return WIRE_MODULE_OUTLINE
		module_types.HEATER:
			return HEATER_MODULE_OUTLINE
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


static func get_asteroid_texture(size: asteroid_types) -> CompressedTexture2D:
	match size:
		asteroid_types.SMALL:
			return SMALL_ASTEROID
		asteroid_types.MEDIUM:
			return MEDIUM_ASTEROID
		asteroid_types.LARGE:
			return LARGE_ASTEROID
	push_error("Could not find type ", size, " in asteroid types")
	return CompressedTexture2D.new()


static func get_asteroid_offset(size: asteroid_types) -> Vector2:
	match size:
		asteroid_types.SMALL:
			return Vector2.ZERO
		asteroid_types.MEDIUM:
			return Vector2(64, 0)
		asteroid_types.LARGE:
			return Vector2(64, 32)
	push_error("Could not find type ", size, " in asteroid types")
	return Vector2.ZERO


static func get_random_cell_type() -> engine_cell_types:
	var types: Array[engine_cell_types] = [engine_cell_types.FUEL, engine_cell_types.COOLANT]
	return types[randi()%2]


static func get_random_hole_position() -> Vector2:
	return Vector2(randi_range(-272, 272), randi_range(-184, 128))


static func get_random_text(length: int) -> String:
	var result: String = ""
	for i in length:
		var random_num: int = (randf() * 127) as int
		if random_num < 33:
			random_num += 33
		result += String.chr(random_num)
	return result
