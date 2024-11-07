extends Node2D


func _on_area_body_entered(body: Node2D) -> void:
	if body.name == "Patch Body":
		print_debug("Patch entered hole")


func _on_area_body_exited(body: Node2D) -> void:
	if body.name == "Patch Body":
		print_debug("Patch exited hole")
