extends Node2D


signal hit(hit_damage: int)


var damage: int = 0


func set_time(time: float) -> void:
	$Timer.wait_time = time
	$Animator.speed_scale = 1.0 / time
	$"Animatior 2".speed_scale = 1.0 / time
	$Animator.play(&"flash")


func get_time() -> float:
	return $Timer.wait_time


func _on_timer_timeout() -> void:
	hit.emit(damage)


func _on_animator_animation_finished(_anim_name: StringName) -> void:
	$Animator.play(&"flash")
	$"Animatior 2".play(&"fade")
	#$Animator.advance($Timer.wait_time - $Timer.time_left)
