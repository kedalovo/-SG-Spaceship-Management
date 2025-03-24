extends Node2D


signal item_bought(item: game_manager.store_items, price: int)
signal balance_flash
signal map_summoned
signal button_hover(btn: store_button)
signal button_hover_stop


@export_color_no_alpha var default_color: Color
@export_color_no_alpha var highlight_color: Color


const HULL_UPGRADE_2 = preload("res://Store/Assets/Hull upgrade 2.png")
const LIFE_SUPPORT_UPGRADE_2 = preload("res://Store/Assets/Life support upgrade 2.png")
const OUT_OF_STOCK = preload("res://Store/Assets/Out of stock.png")


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

@onready var map_button: TextureButton = $"Map Button Background/Map Button"

@onready var input_stopper: Control = $"Input Stopper"


func _ready() -> void:
	toggle_input(true)


func toggle_input(new_state: bool) -> void:
	if new_state:
		input_stopper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		input_stopper.mouse_filter = Control.MOUSE_FILTER_STOP


func _on_item_bought(item: game_manager.store_items, price: int) -> void:
	match item:
		game_manager.store_items.NONE:
			push_error("'NONE' item can not be bought at the store")
		game_manager.store_items.LIFE_SUPPORT_1:
			top_left_button.upgrade = game_manager.store_items.LIFE_SUPPORT_2
			top_left_button.update_texture(LIFE_SUPPORT_UPGRADE_2)
			top_left_button.custom_tooltip = "TOOLTIP_LIFE_SUPPORT_2"
		game_manager.store_items.LIFE_SUPPORT_2:
			top_left_button.update_texture(OUT_OF_STOCK)
			top_left_button.custom_tooltip = "TOOLTIP_OUT_OF_STOCK"
			top_left_button.upgrade = game_manager.store_items.OUT_OF_STOCK
		game_manager.store_items.ENGINES:
			top_middle_button.update_texture(OUT_OF_STOCK)
			top_middle_button.custom_tooltip = "TOOLTIP_OUT_OF_STOCK"
			top_middle_button.upgrade = game_manager.store_items.OUT_OF_STOCK
		game_manager.store_items.HULL_1:
			top_right_button.upgrade = game_manager.store_items.HULL_2
			top_right_button.update_texture(HULL_UPGRADE_2)
			top_right_button.custom_tooltip = "TOOLTIP_HULL_2"
		game_manager.store_items.HULL_2:
			top_right_button.update_texture(OUT_OF_STOCK)
			top_right_button.custom_tooltip = "TOOLTIP_OUT_OF_STOCK"
			top_right_button.upgrade = game_manager.store_items.OUT_OF_STOCK
		game_manager.store_items.CONTROLS:
			bottom_middle_button.update_texture(OUT_OF_STOCK)
			bottom_middle_button.custom_tooltip = "TOOLTIP_OUT_OF_STOCK"
			bottom_middle_button.upgrade = game_manager.store_items.OUT_OF_STOCK
		game_manager.store_items.BALLISTIC:
			bottom_left_button.update_texture(OUT_OF_STOCK)
			bottom_left_button.custom_tooltip = "TOOLTIP_OUT_OF_STOCK"
			bottom_left_button.upgrade = game_manager.store_items.OUT_OF_STOCK
		game_manager.store_items.NAVIGATION:
			bottom_right_button.update_texture(OUT_OF_STOCK)
			bottom_right_button.custom_tooltip = "TOOLTIP_OUT_OF_STOCK"
			bottom_right_button.upgrade = game_manager.store_items.OUT_OF_STOCK
		game_manager.store_items.ALGAE:
			pass
		game_manager.store_items.FUEL_CELL:
			pass
		game_manager.store_items.COOLANT_CELL:
			pass
		game_manager.store_items.PATCH:
			pass
	item_bought.emit(item, price)


func _on_low_balance_flash() -> void:
	balance_flash.emit()


func _on_map_button_pressed() -> void:
	toggle_input(false)
	map_summoned.emit()


func _on_map_button_mouse_entered() -> void:
	map_button.modulate = highlight_color


func _on_map_button_mouse_exited() -> void:
	map_button.modulate = default_color


func _on_store_button_hover(btn: store_button) -> void:
	button_hover.emit(btn)


func _on_store_button_hover_stop() -> void:
	button_hover_stop.emit()
