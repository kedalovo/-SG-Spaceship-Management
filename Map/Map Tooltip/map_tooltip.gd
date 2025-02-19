extends PanelContainer

@onready var label: Label = $Panel/MarginContainer/Label


func set_text(new_text: String) -> void:
	label.text = new_text
	reset_size()
