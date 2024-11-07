extends Node2D


signal patch_installed(hole_index: int)


@onready var mark_1: Sprite2D = $"Screw Marks/Mark 1"
@onready var mark_2: Sprite2D = $"Screw Marks/Mark 2"
@onready var mark_3: Sprite2D = $"Screw Marks/Mark 3"
@onready var mark_4: Sprite2D = $"Screw Marks/Mark 4"
@onready var sprite: Sprite2D = $Sprite

var mounted_on_hole: int


func set_marks(amount: int):
	if amount != 4 and amount != 2:
		push_error("Amount of marks on a patch can only be 2 or 4")
		return
	else:
		if amount == 4:
			mark_1.show()
			mark_2.show()
			mark_3.show()
			mark_4.show()
			sprite.region_rect = Rect2(Vector2.ZERO, Vector2(48, 48))
		else:
			mark_2.show()
			mark_4.show()
			sprite.region_rect = Rect2(Vector2(0, 15), Vector2(48, 18))


func check_completion() -> void:
	if mark_1.modulate * mark_2.modulate * mark_3.modulate * mark_4.modulate == Color.WHITE:
		patch_installed.emit(mounted_on_hole)


func _on_mark_1_pressed() -> void:
	mark_1.modulate = Color.WHITE
	check_completion()


func _on_mark_2_pressed() -> void:
	mark_2.modulate = Color.WHITE
	check_completion()


func _on_mark_3_pressed() -> void:
	mark_3.modulate = Color.WHITE
	check_completion()


func _on_mark_4_pressed() -> void:
	mark_4.modulate = Color.WHITE
	check_completion()
