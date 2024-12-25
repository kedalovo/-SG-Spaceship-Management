extends Node2D


class_name Hazard


signal finished(spot: Vector2, strength: int, type: game_manager.damage_types)


var types: Array[game_manager.damage_types]

var spot: Vector2 = Vector2.ZERO

var strength: int = 0

var is_instant: bool = true


func set_time(time: float) -> void:
	$Timer.wait_time = time


func _on_timer_timeout() -> void:
	if is_instant:
		for i in types:
			finished.emit(spot, strength, i)
	queue_free()


func _on_hurt_timer_timeout() -> void:
	if !is_instant:
		for i in types:
			finished.emit(spot, strength, i)
