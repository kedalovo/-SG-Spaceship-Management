extends Node2D


signal finished(pos: Vector2)


var spot: Vector2


func set_time(time: float) -> void:
	$Sprite/Animator.speed_scale = 1.0 / time


func _on_animator_animation_finished(_anim_name: StringName) -> void:
	finished.emit(spot)
	queue_free()
