extends Node2D


@onready var fog_1: TextureRect = $"Fog 1"
@onready var fog_2: TextureRect = $"Fog 2"
@onready var animator: AnimationPlayer = $Animator


func _ready() -> void:
	fog_1.texture.noise.seed = randi()
	fog_2.texture.noise.seed = randi()


func _physics_process(delta: float) -> void:
	fog_1.texture.noise.offset.x += delta
	fog_2.texture.noise.offset.x += delta * 10


func toggle(on: bool) -> void:
	if on:
		animator.play(&"show")
	else:
		animator.play_backwards(&"show")
