extends Node2D


class_name Blueprint


@onready var sprite: Sprite2D = $Sprite
@onready var area: Area2D = $Area

@onready var type: game_manager.module_types

var y_offset: int = 0


func set_type(new_type: game_manager.module_types) -> void:
	type = new_type
	if sprite == null:
		sprite = $Sprite
	sprite.texture = game_manager.get_blueprint_texture(new_type)
	match new_type:
		game_manager.module_types.PATCH:
			y_offset = 13
		game_manager.module_types.SATELLITE:
			y_offset = -13


func enable_area() -> void:
	area.monitoring = true


func disable_area() -> void:
	area.monitoring = false


func _on_area_body_entered(body: Node2D) -> void:
	var parent = body.get_parent()
	if parent is Module:
		if parent.type == type:
			parent.target_blueprint = self


func _on_area_body_exited(body: Node2D) -> void:
	var parent = body.get_parent()
	if parent is Module:
		parent.target_blueprint = null
