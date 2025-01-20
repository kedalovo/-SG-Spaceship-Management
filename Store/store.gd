extends Node2D


@onready var algae_outline: Sprite2D = $"Buttons/Algae Button/Sprite/Outline"
@onready var fuel_outline: Sprite2D = $"Buttons/Fuel Button/Sprite/Outline"
@onready var coolant_outline: Sprite2D = $"Buttons/Coolant Button/Sprite/Outline"
@onready var patch_outline: Sprite2D = $"Buttons/Patch Button/Sprite/Outline"


func _on_algae_button_pressed() -> void:
	pass # Replace with function body.


func _on_algae_button_mouse_entered() -> void:
	algae_outline.show()


func _on_algae_button_mouse_exited() -> void:
	algae_outline.hide()


func _on_fuel_button_pressed() -> void:
	pass # Replace with function body.


func _on_fuel_button_mouse_entered() -> void:
	fuel_outline.show()


func _on_fuel_button_mouse_exited() -> void:
	fuel_outline.hide()


func _on_coolant_button_pressed() -> void:
	pass # Replace with function body.


func _on_coolant_button_mouse_entered() -> void:
	coolant_outline.show()


func _on_coolant_button_mouse_exited() -> void:
	coolant_outline.hide()


func _on_patch_button_pressed() -> void:
	pass # Replace with function body.


func _on_patch_button_mouse_entered() -> void:
	patch_outline.show()


func _on_patch_button_mouse_exited() -> void:
	patch_outline.hide()
