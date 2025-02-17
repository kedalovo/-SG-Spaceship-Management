extends Control


@onready var title_label: Label = $"Margin/VBox/Title Label"
@onready var content_label: Label = $"Margin/VBox/Content Label"
@onready var animator: AnimationPlayer = $Animator


func set_text(new_text: String) -> void:
	if new_text == "":
		title_label.text = ""
		content_label.text = ""
		return
	var first_break: int = new_text.find("\n")
	title_label.text = new_text.substr(0, first_break - 1)
	content_label.text = new_text.substr(first_break + 2, new_text.length() - first_break - 2)


func toggle(on: bool) -> void:
	match on:
		true:
			animator.play(&"open")
		false:
			animator.play_backwards(&"open")
			set_text("")
