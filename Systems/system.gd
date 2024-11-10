extends Node2D


class_name system


var upgrade_tiers: int
var current_tier: int

var is_damaged: bool


func upgrade(to_tier: int) -> void:
	to_tier = clampi(to_tier, current_tier, upgrade_tiers)


func _damage(_strength: int, _type: game_manager.damage_types) -> void:
	print(name, ": damage is not implemented")


func fix() -> void:
	print(name, ": fixing is not implemented")


func open() -> void:
	show()


func close() -> void:
	hide()
