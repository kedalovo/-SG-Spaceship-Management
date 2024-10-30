extends Node2D


class_name system


var upgrade_tiers: int
var current_tier: int


func upgrade(to_tier: int):
	to_tier = clampi(to_tier, current_tier, upgrade_tiers)


func damage(strength: int, type: game_manager.damage_types):
	pass


func fix():
	pass


func open():
	pass


func close():
	pass
