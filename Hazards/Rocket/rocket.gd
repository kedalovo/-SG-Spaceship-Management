extends Node2D


class_name rocket


signal finished(finished_rocked: rocket)


@onready var sprite: Sprite2D = $Sprite
@onready var animator: AnimationPlayer = $Sprite/Animator


var target: Node2D

var speed: float = 0.0

var damage: int = 0


func _physics_process(delta: float) -> void:
	global_position = global_position.lerp(target.global_position, delta * speed * exp(animator.current_animation_position))
	sprite.look_at(target.global_position)
	sprite.rotate(deg_to_rad(90.0))


func set_time(time: float) -> void:
	$Sprite/Animator.speed_scale = 1.0 / time


func _on_animator_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"start":
		finished.emit(self)
		queue_free()
