extends Node2D


@onready var sprite: Sprite2D = $Sprite


func set_type(new_type: game_manager.module_types) -> void:
	sprite.texture = game_manager.get_module_texture(new_type)
