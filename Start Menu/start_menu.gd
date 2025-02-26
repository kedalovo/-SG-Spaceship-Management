extends Control


@onready var noise: TextureRect = $"Background Container/Noise"
@onready var noise_2: TextureRect = $"Background Container/Noise 2"


func _ready() -> void:
	noise.texture.noise.seed = randi()
	noise_2.texture.noise.seed = randi()
