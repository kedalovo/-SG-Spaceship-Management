extends Node2D


@onready var pos_label: Label = $PosLabel
@onready var particles: Node2D = $Particles
@onready var grid: Node2D = $Grid

var current_pos: Vector2 = Vector2.ZERO


func move(to: Vector2) -> void:
	match to:
		Vector2.UP:
			if current_pos.y >= 0:
				current_pos.y -= 1
				particles.position.y -= 64
				grid.position.y -= 64
		Vector2.DOWN:
			if current_pos.y <= 0:
				current_pos.y += 1
				particles.position.y += 64
				grid.position.y += 64
		Vector2.LEFT:
			if current_pos.x >= 0:
				current_pos.x -= 1
				particles.position.x -= 64
				grid.position.x -= 64
		Vector2.RIGHT:
			if current_pos.x <= 0:
				current_pos.x += 1
				particles.position.x += 64
				grid.position.x += 64
	pos_label.text = str(current_pos)
