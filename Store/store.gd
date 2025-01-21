extends Node2D


signal algae_bought
signal fuel_bought
signal coolant_bought
signal patch_bought
signal upgrade_bought(upgrade: game_manager.upgrades)


@export_color_no_alpha var default_color: Color
@export_color_no_alpha var highlight_color: Color


@onready var algae_outline: Sprite2D = $"Buttons/Algae Button/Sprite/Outline"
@onready var fuel_outline: Sprite2D = $"Buttons/Fuel Button/Sprite/Outline"
@onready var coolant_outline: Sprite2D = $"Buttons/Coolant Button/Sprite/Outline"
@onready var patch_outline: Sprite2D = $"Buttons/Patch Button/Sprite/Outline"

@onready var top_left_button: TextureButton = $"Buttons/Top Left Button"
@onready var top_middle_button: Button = $"Buttons/Top Middle Button"
@onready var top_right_button: TextureButton = $"Buttons/Top Right Button"
@onready var bottom_left_button: TextureButton = $"Buttons/Bottom Left Button"
@onready var bottom_middle_button: Button = $"Buttons/Bottom Middle Button"
@onready var bottom_right_button: TextureButton = $"Buttons/Bottom Right Button"


var current_upgrades: Array = [game_manager.upgrades.LIFE_SUPPORT_1, game_manager.upgrades.ENGINES,
							game_manager.upgrades.HULL_1, game_manager.upgrades.BALLISTIC,
							game_manager.upgrades.CONTROLS, game_manager.upgrades.NAVIGATION]


func buy_upgrade(idx: int) -> void:
	if current_upgrades[0] != null:
		upgrade_bought.emit(current_upgrades[idx])
	match current_upgrades[idx]:
		game_manager.upgrades.LIFE_SUPPORT_1:
			current_upgrades[idx] = game_manager.upgrades.LIFE_SUPPORT_2
		game_manager.upgrades.LIFE_SUPPORT_2:
			current_upgrades[idx] = null
		game_manager.upgrades.HULL_1:
			current_upgrades[idx] = game_manager.upgrades.HULL_2
		game_manager.upgrades.HULL_2:
			current_upgrades[idx] = null


func _on_algae_button_pressed() -> void:
	algae_bought.emit()


func _on_algae_button_mouse_entered() -> void:
	algae_outline.show()


func _on_algae_button_mouse_exited() -> void:
	algae_outline.hide()


func _on_fuel_button_pressed() -> void:
	fuel_bought.emit()


func _on_fuel_button_mouse_entered() -> void:
	fuel_outline.show()


func _on_fuel_button_mouse_exited() -> void:
	fuel_outline.hide()


func _on_coolant_button_pressed() -> void:
	coolant_bought.emit()


func _on_coolant_button_mouse_entered() -> void:
	coolant_outline.show()


func _on_coolant_button_mouse_exited() -> void:
	coolant_outline.hide()


func _on_patch_button_pressed() -> void:
	patch_bought.emit()


func _on_patch_button_mouse_entered() -> void:
	patch_outline.show()


func _on_patch_button_mouse_exited() -> void:
	patch_outline.hide()


func _on_top_left_button_pressed() -> void:
	buy_upgrade(0)


func _on_top_left_button_mouse_entered() -> void:
	top_left_button.modulate = highlight_color


func _on_top_left_button_mouse_exited() -> void:
	top_left_button.modulate = default_color


func _on_top_middle_button_pressed() -> void:
	buy_upgrade(1)


func _on_top_middle_button_mouse_entered() -> void:
	top_middle_button.modulate = highlight_color


func _on_top_middle_button_mouse_exited() -> void:
	top_middle_button.modulate = default_color


func _on_top_right_button_pressed() -> void:
	buy_upgrade(2)


func _on_top_right_button_mouse_entered() -> void:
	top_right_button.modulate = highlight_color


func _on_top_right_button_mouse_exited() -> void:
	top_right_button.modulate = default_color


func _on_bottom_left_button_pressed() -> void:
	buy_upgrade(3)


func _on_bottom_left_button_mouse_entered() -> void:
	bottom_left_button.modulate = highlight_color


func _on_bottom_left_button_mouse_exited() -> void:
	bottom_left_button.modulate = default_color


func _on_bottom_middle_button_pressed() -> void:
	buy_upgrade(4)


func _on_bottom_middle_button_mouse_entered() -> void:
	bottom_middle_button.modulate = highlight_color


func _on_bottom_middle_button_mouse_exited() -> void:
	bottom_middle_button.modulate = default_color


func _on_bottom_right_button_pressed() -> void:
	buy_upgrade(5)


func _on_bottom_right_button_mouse_entered() -> void:
	bottom_right_button.modulate = highlight_color


func _on_bottom_right_button_mouse_exited() -> void:
	bottom_right_button.modulate = default_color
