extends Node2D


class_name Hole


var index: int = -1


func _on_area_body_entered(body: Node2D) -> void:
	if body.name == "Patch Body":
		body.get_parent().is_hovering_hole = true
		body.get_parent().mounted_on_hole = self


func _on_area_body_exited(body: Node2D) -> void:
	if body.name == "Patch Body":
		body.get_parent().is_hovering_hole = false
		body.get_parent().mounted_on_hole = null
