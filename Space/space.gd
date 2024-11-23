extends Node2D


@onready var pos_label: Label = $PosLabel
@onready var particles: Node2D = $Particles
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
				var new_pos := MIDDLE_POSITION.y + current_pos.y * 64
				tween.tween_property(particles, "position:y", new_pos, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				tween.set_parallel()
				tween.tween_property(grid, "position:y", new_pos, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				is_set = true
		Vector2.DOWN:
			if current_pos.y <= 0:
				current_pos.y += 1
				var new_pos := MIDDLE_POSITION.y + current_pos.y * 64
				tween.tween_property(particles, "position:y", new_pos, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				tween.set_parallel()
				tween.tween_property(grid, "position:y", new_pos, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				is_set = true
		Vector2.LEFT:
			if current_pos.x >= 0:
				current_pos.x -= 1
				var new_pos := MIDDLE_POSITION.x + current_pos.x * 64
				tween.tween_property(particles, "position:x", new_pos, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				tween.set_parallel()
				tween.tween_property(grid, "position:x", new_pos, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				is_set = true
		Vector2.RIGHT:
			if current_pos.x <= 0:
				current_pos.x += 1
				var new_pos := MIDDLE_POSITION.x + current_pos.x * 64
				tween.tween_property(particles, "position:x", new_pos, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				tween.set_parallel()
				tween.tween_property(grid, "position:x", new_pos, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				is_set = true
	if is_set:
		tween.tween_callback(func(): is_moving = false).set_delay(TWEEN_TIME-0.1)
		is_moving = true
		pos_label.text = str(current_pos)
	else:
		tween.kill()
