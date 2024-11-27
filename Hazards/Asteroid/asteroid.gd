extends Node2D


func set_visuals(size: game_manager.asteroid_types, is_vertical: bool) -> void:
	$Sprite.texture = game_manager.get_asteroid_texture(size)
	$Sprite.position = game_manager.get_asteroid_offset(size)
	if is_vertical:
		$Sprite.rotation_degrees = 90.0
		var new_pos = game_manager.get_asteroid_offset(size)
		$Sprite.position = Vector2(new_pos.y, new_pos.x)


func set_types(types: Array[game_manager.damage_types]) -> void:
	print_debug("Asteroid types: ", types)


func set_time(time: float) -> void:
	$Timer.wait_time = time
	$Sprite/Animator.speed_scale = 10.0 / time


func _on_timer_timeout() -> void:
	queue_free()
