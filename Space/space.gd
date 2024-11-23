extends Node2D


@onready var particles: Node2D = $Particles
@onready var far_particles: GPUParticles2D = $"Particles/Far Particles"
@onready var middle_particles: GPUParticles2D = $"Particles/Middle Particles"
@onready var close_particles: GPUParticles2D = $"Particles/Close Particles"
@onready var grid: Node2D = $Grid

const MIDDLE_POSITION: Vector2 = Vector2(128, 192)
const TWEEN_TIME: float = 0.3

var current_pos: Vector2 = Vector2.ZERO

var is_moving: bool = false


func move(to: Vector2) -> void:
	if is_moving:
		return
	var is_set: bool = false
	var tween: Tween = get_tree().create_tween()
	match to:
		Vector2.UP:
			if current_pos.y >= 0:
				current_pos.y -= 1
				var new_pos := current_pos.y * 64
				var new_pos_mid := current_pos.y * 48
				var new_pos_close := current_pos.y * 32
				tween.set_parallel()
				tween.tween_property(far_particles, "position:y", new_pos, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				tween.tween_property(middle_particles, "position:y", new_pos_mid, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				tween.tween_property(close_particles, "position:y", new_pos_close, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				tween.tween_property(grid, "position:y", MIDDLE_POSITION.y + new_pos, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				is_set = true
		Vector2.DOWN:
			if current_pos.y <= 0:
				current_pos.y += 1
				var new_pos := current_pos.y * 64
				var new_pos_mid := current_pos.y * 48
				var new_pos_close := current_pos.y * 32
				tween.set_parallel()
				tween.tween_property(far_particles, "position:y", new_pos, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				tween.tween_property(middle_particles, "position:y", new_pos_mid, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				tween.tween_property(close_particles, "position:y", new_pos_close, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				tween.tween_property(grid, "position:y", MIDDLE_POSITION.y + new_pos, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				is_set = true
		Vector2.LEFT:
			if current_pos.x >= 0:
				current_pos.x -= 1
				var new_pos := current_pos.x * 64
				var new_pos_mid := current_pos.x * 48
				var new_pos_close := current_pos.x * 32
				tween.set_parallel()
				tween.tween_property(far_particles, "position:x", new_pos, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				tween.tween_property(middle_particles, "position:x", new_pos_mid, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				tween.tween_property(close_particles, "position:x", new_pos_close, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				tween.tween_property(grid, "position:x", MIDDLE_POSITION.x + new_pos, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				is_set = true
		Vector2.RIGHT:
			if current_pos.x <= 0:
				current_pos.x += 1
				var new_pos := current_pos.x * 64
				var new_pos_mid := current_pos.x * 48
				var new_pos_close := current_pos.x * 32
				tween.set_parallel()
				tween.tween_property(far_particles, "position:x", new_pos, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				tween.tween_property(middle_particles, "position:x", new_pos_mid, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				tween.tween_property(close_particles, "position:x", new_pos_close, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				tween.tween_property(grid, "position:x", MIDDLE_POSITION.x + new_pos, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				is_set = true
	if is_set:
		tween.tween_callback(func(): is_moving = false).set_delay(TWEEN_TIME-0.1)
		is_moving = true
	else:
		tween.kill()
