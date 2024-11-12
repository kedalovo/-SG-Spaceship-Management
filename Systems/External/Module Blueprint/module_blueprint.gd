extends Node2D


class_name Blueprint


@onready var sprite: Sprite2D = $Sprite

@onready var type: game_manager.module_types


func set_type(new_type: game_manager.module_types) -> void:
	type = new_type
	if sprite == null:
		sprite = $Sprite
	sprite.texture = game_manager.get_blueprint_texture(new_type)


func _on_area_body_entered(body: Node2D) -> void:
	print("Body entered!")


func _on_area_body_exited(body: Node2D) -> void:
	pass
