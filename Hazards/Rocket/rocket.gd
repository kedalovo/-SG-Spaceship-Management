extends Node2D


@onready var sprite: Sprite2D = $Sprite


var target: Node2D

var speed: float = 0.0


func _physics_process(delta: float) -> void:
	global_position = global_position.lerp(target.global_position, delta * speed)
	sprite.look_at(target.global_position)
	sprite.rotate(deg_to_rad(90.0))


func _on_timer_timeout() -> void:
	pass # Replace with function body.
