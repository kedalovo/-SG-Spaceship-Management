extends system


const CODE_LINE = preload("res://Systems/Computer/Code Line/code_line.tscn")


@onready var puzzle_v_box: VBoxContainer = $UI/Margin/HBox/PuzzleVBox
@onready var pieces_v_box: VBoxContainer = $UI/Margin/HBox/PiecesVBox
@onready var camera: Camera2D = $Camera2D

@onready var code_line_press_audio: AudioStreamPlayer = $"Code Line Press Audio"
@onready var code_line_hover_audio: AudioStreamPlayer = $"Code Line Hover Audio"

var busy_puzzle_slots: Array[bool] = [false, false, false, false, false, false]
var busy_pieces_slots: Array[bool] = [false, false, false, false, false, false]

var slots: Array[CodeLine] = []


func _damage(_strength: int, _type: game_manager.damage_types) -> void:
	if _type == game_manager.damage_types.ELECTRICITY:
		if is_damaged:
			return
		print("🖥️Computer system: damaged")
		is_damaged = true
		create_random_pattern(_strength)


func create_random_pattern(size: int) -> void:
	size = clampi(size, 3, 6)
	match randi()%4:
		0:
			var length: int = randi()%4 + 4
			var array: Array[int] = []
			for i in size:
				array.append(1)
			array[0] = 0
			array.shuffle()
			var right := array.duplicate()
			right.shuffle()
			for i in array:
				if i == 0:
					add_empty_slot(length)
				else:
					add_code_line(false, game_manager.get_random_text(length))
			for i in right:
				if i == 0:
					add_code_line(true, game_manager.get_random_text(length))
				else:
					add_code_line(true, game_manager.get_random_text(length - ([-2, -1, 1, 2].pick_random())))
		1:
			var length: int = randi()%3 + 6
			var array: Array[int] = []
			for i in size:
				array.append(1)
			array[0] = 0
			array.shuffle()
			var right := array.duplicate()
			right.shuffle()
			var idx: int = array.find(0)
			for i in array.size():
				if array[i] == 1:
					add_code_line(false, game_manager.get_random_text(length - absi(idx - i)))
				else:
					add_empty_slot(length - absi(idx - i))
			for i in right:
				if i == 0:
					add_code_line(true, game_manager.get_random_text(length))
				else:
					add_code_line(true, game_manager.get_random_text(length - ([-2, -1, 1, 2].pick_random())))
		2:
			var length: int = randi()%4 + 2
			var array: Array[int] = []
			for i in size:
				array.append(1)
			array[0] = 0
			array.shuffle()
			var right := array.duplicate()
			right.shuffle()
			var idx: int = array.find(0)
			for i in array.size():
				if array[i] == 1:
					add_code_line(false, game_manager.get_random_text(length + absi(idx - i)))
				else:
					add_empty_slot(length + absi(idx - i))
			for i in right:
				if i == 0:
					add_code_line(true, game_manager.get_random_text(length))
				else:
					add_code_line(true, game_manager.get_random_text(length - ([-2, -1, 1, 2].pick_random())))
		3:
			var length: int = randi()%3 + 6
			var array: Array[int] = []
			for i in size:
				array.append(1)
			array[0] = 0
			array.shuffle()
			var right := array.duplicate()
			right.shuffle()
			var idx: int = array.find(0)
			for i in array.size():
				if array[i] == 1:
					add_code_line(false, game_manager.get_random_text(length - (idx - i)))
				else:
					add_empty_slot(length - (idx - i))
			for i in right:
				if i == 0:
					add_code_line(true, game_manager.get_random_text(length))
				else:
					add_code_line(true, game_manager.get_random_text(length - ([-2, -1, 1, 2].pick_random())))


func add_empty_slot(new_length: int) -> void:
	var code_line: CodeLine = CODE_LINE.instantiate()
	code_line.set_slot(new_length)
	code_line.set_text("missing...")
	code_line.installed_correct_line.connect(_on_installed_correct_line)
	slots.append(code_line)
	for slot_idx in busy_puzzle_slots.size():
		if !busy_puzzle_slots[slot_idx]:
			busy_puzzle_slots[slot_idx] = true
			var pos: Control = puzzle_v_box.get_child(slot_idx)
			pos.add_child(code_line)
			pos.show()
			break


func add_code_line(is_right: bool, text: String) -> void:
	var added: bool = false
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
				added = true
				code_line.mouse_entered.connect(_on_code_line_mouse_entered)
				code_line.button_down.connect(_on_code_line_button_down)
				code_line.button_up.connect(_on_code_line_button_up)
				break
	else:
		for slot_idx in busy_puzzle_slots.size():
			if !busy_puzzle_slots[slot_idx]:
				busy_puzzle_slots[slot_idx] = true
				var pos: Control = puzzle_v_box.get_child(slot_idx)
				pos.add_child(code_line)
				pos.show()
				added = true
				break
	if !added:
		push_warning("Couldn't add code_line, all slots are busy. Right: ", code_line.is_on_right)
		code_line.queue_free()


func _on_installed_correct_line(_line: CodeLine, _slot: CodeLine) -> void:
	for pos in pieces_v_box.get_children():
		for child in pos.get_children():
			child.queue_free()
	for pos in puzzle_v_box.get_children():
		for child in pos.get_children():
			child.queue_free()
	fix()


func _on_code_line_mouse_entered() -> void:
	code_line_hover_audio.play()


func _on_code_line_button_down() -> void:
	code_line_press_audio.play()


func _on_code_line_button_up() -> void:
	code_line_press_audio.play()
