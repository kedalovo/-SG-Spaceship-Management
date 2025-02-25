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

const LARGE_NEBULA = preload("res://Hazards/Nebula/Assets/Nebula 3x2.png")
const MEDIUM_NEBULA = preload("res://Hazards/Nebula/Assets/Nebula 2x2.png")
const SMALL_NEBULA = preload("res://Hazards/Nebula/Assets/Nebula 1x1.png")

const WIRE_COLORS: Array[Color] = [Color.RED, Color.BLUE, Color.YELLOW, Color.GREEN, Color.MAGENTA]

const POINT_SYMBOL: String = "◆"

static var wear_modifier: float = 1.0

static var balance: int:
	set(val):
		balance = clampi(val, 0, 10)
	get:
		return balance

static var is_in_system: bool = false

static var is_playing: bool = false

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

enum nebula_types {
	SMALL,
	MEDIUM,
	LARGE
}

enum hazard_types {
	ASTEROID_FIELD,
	WARZONE,
	NEBULA,
	ICE_FIELD,
	STAR_PROXIMITY
}

enum store_items {
	NONE,
	LIFE_SUPPORT_1,
	LIFE_SUPPORT_2,
	ENGINES,
	HULL_1,
	HULL_2,
	CONTROLS,
	BALLISTIC,
	NAVIGATION,
	ALGAE,
	FUEL_CELL,
	COOLANT_CELL,
	PATCH
}

static func get_module_texture(module_type: module_types) -> Texture2D:
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


static func get_module_outline_texture(module_type: module_types) -> Texture2D:
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


static func get_blueprint_texture(blueprint_type: module_types) -> Texture2D:
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


static func get_asteroid_texture(size: asteroid_types) -> Texture2D:
	match size:
		asteroid_types.SMALL:
			return SMALL_ASTEROID
		asteroid_types.MEDIUM:
			return MEDIUM_ASTEROID
		asteroid_types.LARGE:
			return LARGE_ASTEROID
	push_error("Could not find type ", str(size), " in asteroid types")
	return Texture2D.new()


static func get_asteroid_offset(size: asteroid_types) -> Vector2:
	match size:
		asteroid_types.SMALL:
			return Vector2.ZERO
		asteroid_types.MEDIUM:
			return Vector2(64, 0)
		asteroid_types.LARGE:
			return Vector2(64, 32)
	push_error("Could not find type ", str(size), " in asteroid types")
	return Vector2.ZERO


static func get_nebula_texture(size: nebula_types) -> Texture2D:
	match size:
		nebula_types.SMALL:
			return SMALL_NEBULA
		nebula_types.MEDIUM:
			return MEDIUM_NEBULA
		nebula_types.LARGE:
			return LARGE_NEBULA
	push_error("Could not find type ", str(size), " in nebula types")
	return Texture2D.new()


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


static func get_map_node_tooltip(node: map_node) -> String:
	var result: String = ""
	for hazard_idx in node.hazards.size():
		var haz := node.hazards[hazard_idx]
		if node.hazards_types.size() == 0:
			result += get_hazard_text(haz, true) + ".\n"
		else:
			var haz_types: Array = node.hazards_types[hazard_idx]
			if haz_types.is_empty():
				result += get_hazard_text(haz, true) + ".\n"
			else:
				result += get_hazard_variation_text(haz_types) + get_hazard_text(haz) + ".\n"
	result += "\n" + get_hazard_list_text(node)
	return result


static func get_hazard_text(haz_type: hazard_types, is_start: bool = false) -> String:
	var res: String = ""
	match haz_type:
		hazard_types.ASTEROID_FIELD:
			res = "ASTEROID_FIELD"
		hazard_types.WARZONE:
			res = "WARZONE"
		hazard_types.NEBULA:
			res = "NEBULAE"
		hazard_types.ICE_FIELD:
			res = "ICE_FIELD"
		hazard_types.STAR_PROXIMITY:
			res = "STAR_PROXIMITY"
	if is_start:
		if res.length() < 9:
			res = res.capitalize()
		else:
			res = res.substr(0, res.find(" ")).capitalize() + res.substr(res.find(" "))
	return res


static func get_hazard_variation_text(variations: Array) -> String:
	var res: String = ""
	if variations.size() == 2:
		match variations[0]:
			damage_types.HEAT:
				res += "FIERY".capitalize() + " "
			damage_types.ELECTRICITY:
				res += "ELECTRIC".capitalize() + " "
		match variations[1]:
			damage_types.HEAT:
				res += "FIERY" + " "
			damage_types.ELECTRICITY:
				res += "ELECTRIC" + " "
	else:
		match variations[0]:
			damage_types.HEAT:
				res += "FIERY".capitalize() + " "
			damage_types.ELECTRICITY:
				res += "ELECTRIC".capitalize() + " "
	return res


static func get_hazard_list_text(node: map_node) -> String:
	var res: String = ""
	for i in node.hazards.size():
		var haz: hazard_types = node.hazards[i]
		var temp_res: String = ""
		match haz:
			hazard_types.ASTEROID_FIELD:
				temp_res += POINT_SYMBOL + " " + "PHYSICAL_ASTEROIDS" + "\n"
				if node.hazards_types.size() > 0:
					for dam_type in node.hazards_types[i]:
						if dam_type == damage_types.HEAT:
							temp_res += POINT_SYMBOL + " " + "FIERY_ASTEROIDS" + "\n"
						elif dam_type == damage_types.ELECTRICITY:
							temp_res += POINT_SYMBOL + " " + "ELECTRIC_ASTEROIDS" + "\n"
			hazard_types.WARZONE:
				temp_res += POINT_SYMBOL + " " + "PHYSICAL_ROCKETS" + "\n"
			hazard_types.NEBULA:
				temp_res += POINT_SYMBOL + " " + "ELECTRIC_NEBULAE" + "\n"
				if node.hazards_types.size() > 0:
					for dam_type in node.hazards_types[i]:
						if dam_type == damage_types.HEAT:
							temp_res += POINT_SYMBOL + " " + "FIERY_NEBULAE" + "\n"
			hazard_types.ICE_FIELD:
				temp_res += POINT_SYMBOL + " " + "ABNORMAL_TEMPERATURES" + "\n"
			hazard_types.STAR_PROXIMITY:
				temp_res += POINT_SYMBOL + " " + "SOLAR_FLARES" + "\n"
		res += temp_res
	return res
