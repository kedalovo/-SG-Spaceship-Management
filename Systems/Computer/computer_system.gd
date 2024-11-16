extends system


const CODE_LINE = preload("res://Systems/Computer/Code Line/code_line.tscn")


@onready var puzzle_v_box: VBoxContainer = $UI/Margin/HBox/PuzzleVBox
@onready var pieces_v_box: VBoxContainer = $UI/Margin/HBox/PiecesVBox

var busy_puzzle_slots: Array[bool] = [false, false, false, false, false]
var busy_pieces_slots: Array[bool] = [false, false, false, false, false]


func _ready() -> void:
	for i in 2:
		add_code_line(false, game_manager.get_random_text(5))
	add_empty_slot()
	for i in 2:
		add_code_line(false, game_manager.get_random_text(5))
	for i in 2:
		add_code_line(true, game_manager.get_random_text(6))


func add_empty_slot() -> void:
	var code_line: CodeLine = CODE_LINE.instantiate()
	code_line.set_slot()
	code_line.set_text("")
	for slot_idx in busy_puzzle_slots.size():
		if !busy_puzzle_slots[slot_idx]:
			busy_puzzle_slots[slot_idx] = true
			var pos: Control = puzzle_v_box.get_child(slot_idx)
			pos.add_child(code_line)
			pos.show()
			break


func add_code_line(is_right: bool, text: String) -> void:
	var code_line: CodeLine = CODE_LINE.instantiate()
	code_line.set_type(is_right)
	code_line.set_text(text)
	if is_right:
		for slot_idx in busy_pieces_slots.size():
			if !busy_pieces_slots[slot_idx]:
				busy_pieces_slots[slot_idx] = true
				var pos: Control = pieces_v_box.get_child(slot_idx)
				pos.add_child(code_line)
				pos.show()
				break
	else:
		for slot_idx in busy_puzzle_slots.size():
			if !busy_puzzle_slots[slot_idx]:
				busy_puzzle_slots[slot_idx] = true
				var pos: Control = puzzle_v_box.get_child(slot_idx)
				pos.add_child(code_line)
				pos.show()
				break
