extends Node2D


class_name Hazard


signal finished(spot: Vector2, strength: int, type: game_manager.damage_types)


var types: Array[game_manager.damage_types]

var spot: Vector2 = Vector2.ZERO

var strength: int = 0


func set_time(time: float) -> void:
	$Timer.wait_time = time


func _on_timer_timeout() -> void:
	for i in types:
		finished.emit(spot, strength, i)
	queue_free()
