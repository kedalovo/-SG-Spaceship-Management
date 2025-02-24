extends PanelContainer

@onready var label: Label = $Panel/MarginContainer/Label


func _ready() -> void:
	modulate = Color(Color.WHITE, 0.0)


func set_text(new_text: String) -> void:
	label.text = new_text
	reset_size()


func toggle_open(on: bool) -> void:
	if on:
		modulate = Color.WHITE
	else:
		modulate = Color.TRANSPARENT
