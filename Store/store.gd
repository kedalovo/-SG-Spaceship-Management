extends Node2D


signal algae_bought
signal fuel_bought
signal coolant_bought
signal patch_bought
signal item_bought(item: game_manager.store_items)


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


var current_upgrades: Array = [game_manager.store_items.LIFE_SUPPORT_1, game_manager.store_items.ENGINES,
							game_manager.store_items.HULL_1, game_manager.store_items.BALLISTIC,
							game_manager.store_items.CONTROLS, game_manager.store_items.NAVIGATION]


func buy_item(idx: int) -> void:
	if current_upgrades[0] != null:
		item_bought.emit(current_upgrades[idx])
	match current_upgrades[idx]:
		game_manager.store_items.LIFE_SUPPORT_1:
			current_upgrades[idx] = game_manager.store_items.LIFE_SUPPORT_2
		game_manager.store_items.LIFE_SUPPORT_2:
			current_upgrades[idx] = null
		game_manager.store_items.HULL_1:
			current_upgrades[idx] = game_manager.store_items.HULL_2
		game_manager.store_items.HULL_2:
			current_upgrades[idx] = null
