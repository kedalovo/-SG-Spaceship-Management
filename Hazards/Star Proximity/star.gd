extends Node2D


signal hit(hit_damage: int)


var damage: int = 0


func set_time(time: float) -> void:
	$Timer.wait_time = time


func get_time() -> float:
	return $Timer.wait_time


func _on_timer_timeout() -> void:
	hit.emit(damage)
