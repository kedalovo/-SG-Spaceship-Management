extends Node2D


func set_texture(size: game_manager.asteroid_types) -> void:
	$Sprite.texture = game_manager.get_asteroid_texture(size)
	$Sprite.offset = game_manager.get_asteroid_offset(size)


func set_types(types: Array[game_manager.damage_types]) -> void:
	print_debug("Asteroid types: ", types)


func set_time(time: float) -> void:
	$Timer.wait_time = time


func _on_timer_timeout() -> void:
	queue_free()
