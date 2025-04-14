extends Node2D


class_name Hazard


signal hit(spot: Vector2, strength: int, type: game_manager.damage_types)
signal finished(hazard: Hazard)


@onready var progress: TextureProgressBar = $Progress
@onready var ballistic_lines: Sprite2D = $"Ballistic Lines"
@onready var timer: Timer = $Timer


var types: Array[game_manager.damage_types]

var spot: Vector2 = Vector2.ZERO

var strength: int = 0

var is_instant: bool = true


func _ready() -> void:
	if game_manager.is_ballistic:
		set_physics_process(true)
		progress.show()
		ballistic_lines.show()
	else:
		set_physics_process(false)
		progress.hide()
		ballistic_lines.hide()


func _physics_process(_delta: float) -> void:
	progress.value = (timer.wait_time - timer.time_left) / timer.wait_time * 100


func set_time(time: float) -> void:
	$Timer.wait_time = time


func set_hurt_time(time: float) -> void:
	$"Hurt Timer".wait_time = time


func _on_timer_timeout() -> void:
	if is_instant:
		for i in types:
			hit.emit(spot, strength, i)
		print("[HAZARD] Hit at ", spot, " with ", types.size(), " types")
	finished.emit(self)


func _on_hurt_timer_timeout() -> void:
	if !is_instant:
		for i in types:
			hit.emit(spot, strength, i)
		print("[HAZARD] Regular hit at ", spot, " with ", types.size(), " types")
