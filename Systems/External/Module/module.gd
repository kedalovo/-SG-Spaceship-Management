extends Node2D


class_name Module


signal installed(blueprint: Blueprint, module: Module)


@onready var sprite: Sprite2D = $Sprite
@onready var outline: Sprite2D = $Outline

@onready var type: game_manager.module_types

var target_blueprint: Blueprint
var installed_on: Blueprint

var initial_position: Vector2 = Vector2.ZERO

var is_held: bool = false
var is_installed: bool = false


func _physics_process(_delta: float) -> void:
	if is_held:
		global_position = get_global_mouse_position()


func set_type(new_type: game_manager.module_types) -> void:
	type = new_type
	if sprite == null or outline == null:
		sprite = $Sprite
		outline = $Outline
	sprite.texture = game_manager.get_module_texture(new_type)
	outline.texture = game_manager.get_module_outline_texture(new_type)


func _on_button_button_down() -> void:
	if !is_installed:
		is_held = true
		outline.hide()


func _on_button_button_up() -> void:
	is_held = false
	if target_blueprint != null:
		installed_on = target_blueprint
		target_blueprint = null
		global_position = installed_on.global_position
		is_installed = true
		installed.emit(installed_on, self)
	else:
		position = initial_position


func _on_button_mouse_entered() -> void:
	if !is_installed and !is_held:
		outline.show()


func _on_button_mouse_exited() -> void:
	outline.hide()
