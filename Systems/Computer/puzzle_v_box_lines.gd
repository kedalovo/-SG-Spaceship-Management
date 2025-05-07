extends VBoxContainer


var points: Array[Control] = []


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	for i in points.size() - 1:
		var p1: Control = points[i]
		var p2: Control = points[i+1]
		var c1: CodeLine = p1.get_child(0)
		var c2: CodeLine = p2.get_child(0)
		var x1: float = p1.position.x + c1.length * 2 + 50
		if c1.is_slot:
			x1 = p1.position.x + c1.slot_length * 2 + 50
		var x2: float = p2.position.x + c2.length * 2 + 50
		if c2.is_slot:
			x2 = p2.position.x + c2.slot_length * 2 + 50
		var y1: float = p1.position.y + 4
		var y2: float = p2.position.y + 4
		draw_line(Vector2(x1, y1), Vector2(x2, y2), Color(0.21, 0.48, 0.39), 2)
		draw_circle(Vector2(x1, y1), 3, Color(0.285, 0.574, 0.478))
		draw_circle(Vector2(x2, y2), 3, Color(0.285, 0.574, 0.478))
