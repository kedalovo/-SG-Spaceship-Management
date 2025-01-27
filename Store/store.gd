extends Node2D


signal algae_bought
signal fuel_bought
signal coolant_bought
signal patch_bought
signal item_bought(item: game_manager.store_items)


@export_color_no_alpha var default_color: Color
@export_color_no_alpha var highlight_color: Color


const HULL_UPGRADE_2 = preload("res://Store/Assets/Hull upgrade 2.png")
const LIFE_SUPPORT_UPGRADE_2 = preload("res://Store/Assets/Life support upgrade 2.png")


@onready var algae_outline: Sprite2D = $"Buttons/Algae Button/Sprite/Outline"
@onready var fuel_outline: Sprite2D = $"Buttons/Fuel Button/Sprite/Outline"
@onready var coolant_outline: Sprite2D = $"Buttons/Coolant Button/Sprite/Outline"
@onready var patch_outline: Sprite2D = $"Buttons/Patch Button/Sprite/Outline"

@onready var top_left_button: TextureButton = $"Buttons/Top Left Button"
@onready var top_middle_button: TextureButton = $"Buttons/Top Middle Button"
@onready var top_right_button: TextureButton = $"Buttons/Top Right Button"
@onready var bottom_left_button: TextureButton = $"Buttons/Bottom Left Button"
@onready var bottom_middle_button: TextureButton = $"Buttons/Bottom Middle Button"
@onready var bottom_right_button: TextureButton = $"Buttons/Bottom Right Button"


func _on_item_bought(item: game_manager.store_items) -> void:
	match item:
		game_manager.store_items.NONE:
			push_error("'NONE' item can not be bought at the store")
		game_manager.store_items.LIFE_SUPPORT_1:
			top_left_button.upgrade = game_manager.store_items.LIFE_SUPPORT_2
			top_left_button.update_texture(LIFE_SUPPORT_UPGRADE_2)
			item_bought.emit(game_manager.store_items.LIFE_SUPPORT_1)
		game_manager.store_items.LIFE_SUPPORT_2:
			item_bought.emit(game_manager.store_items.LIFE_SUPPORT_2)
		game_manager.store_items.ENGINES:
			item_bought.emit(game_manager.store_items.ENGINES)
		game_manager.store_items.HULL_1:
			top_right_button.upgrade = game_manager.store_items.HULL_2
			top_right_button.update_texture(HULL_UPGRADE_2)
			item_bought.emit(game_manager.store_items.HULL_1)
		game_manager.store_items.HULL_2:
			item_bought.emit(game_manager.store_items.HULL_2)
		game_manager.store_items.CONTROLS:
			item_bought.emit(game_manager.store_items.CONTROLS)
		game_manager.store_items.BALLISTIC:
			item_bought.emit(game_manager.store_items.BALLISTIC)
		game_manager.store_items.NAVIGATION:
			item_bought.emit(game_manager.store_items.NAVIGATION)
		game_manager.store_items.ALGAE:
			algae_bought.emit()
		game_manager.store_items.FUEL_CELL:
			fuel_bought.emit()
		game_manager.store_items.COOLANT_CELL:
			coolant_bought.emit()
		game_manager.store_items.PATCH:
			patch_bought.emit()
