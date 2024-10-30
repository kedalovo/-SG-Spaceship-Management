extends Sprite2D


@onready var outline: Sprite2D = $Outline


func _on_mouse_area_mouse_entered() -> void:
	outline.visible = true


func _on_mouse_area_mouse_exited() -> void:
	outline.visible = false
