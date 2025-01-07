extends Node2D


@onready var dot: ColorRect = $Dot
@onready var digit_1: Sprite2D = $"Digits/Digit 1"
@onready var digit_2: Sprite2D = $"Digits/Digit 2"
@onready var digit_3: Sprite2D = $"Digits/Digit 3"


func set_time(time: float) -> void:
	if time == 0.0:
		return
	var floored: int = floori(time)
	var str_floored: String = str(floored)
	if floored > 99:
		dot.hide()
		digit_1.region_rect = Rect2(str_floored[0].to_int() * 22, 0, 22, 38)
		digit_2.region_rect = Rect2(str_floored[1].to_int() * 22, 0, 22, 38)
		digit_3.region_rect = Rect2(str_floored[2].to_int() * 22, 0, 22, 38)
	elif floored > 9:
		dot.hide()
		digit_1.region_rect = Rect2(0, 0, 22, 38)
		digit_2.region_rect = Rect2(str_floored[0].to_int() * 22, 0, 22, 38)
		digit_3.region_rect = Rect2(str_floored[1].to_int() * 22, 0, 22, 38)
	else:
		var str_time: String = str(time)
		dot.show()
		digit_1.region_rect = Rect2(str_time[0].to_int() * 22, 0, 22, 38)
		digit_2.region_rect = Rect2(str_time[2].to_int() * 22, 0, 22, 38)
		digit_3.region_rect = Rect2(str_time[3].to_int() * 22, 0, 22, 38)
