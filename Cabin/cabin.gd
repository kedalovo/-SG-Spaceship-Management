extends Node2D


@onready var dirt: TextureRect = $"Cabin View/Dirt"
@onready var animator: AnimationPlayer = $"Cabin View/Animator"


func toggle_dirt(on: bool) -> void:
	match on:
		true:
			dirt.texture.noise.seed = randi()
			animator.play(&"show")
		false:
			animator.play(&"hide")
