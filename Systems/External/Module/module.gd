extends Node2D


class_name Module


@onready var sprite: Sprite2D = $Sprite

@onready var type: game_manager.module_types


func set_type(new_type: game_manager.module_types) -> void:
	type = new_type
	if sprite == null:
		sprite = $Sprite
	sprite.texture = game_manager.get_module_texture(new_type)
