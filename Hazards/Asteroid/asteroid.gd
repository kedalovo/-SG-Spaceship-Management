extends Node2D


func set_visuals(size: game_manager.asteroid_types, is_vertical: bool) -> void:
	$Pivot/Sprite.texture = game_manager.get_asteroid_texture(size)
	if is_vertical:
		$Pivot/Sprite.rotation_degrees = 90.0


func set_types(types: Array[game_manager.damage_types]) -> void:
	for type in types:
		match type:
			game_manager.damage_types.HEAT:
				$"Pivot/Sprite/Fire Particles".emitting = true
			game_manager.damage_types.ELECTRICITY:
				$"Pivot/Sprite/Electricity Particles".emitting = true


func set_time(time: float) -> void:
	$Timer.wait_time = time
	$Pivot/Sprite/Animator.speed_scale = 10.0 / time


func _on_timer_timeout() -> void:
	queue_free()
