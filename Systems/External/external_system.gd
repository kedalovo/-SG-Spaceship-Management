extends system


@onready var module_1: Node2D = $"Module Places/Module 1"
@onready var module_2: Node2D = $"Module Places/Module 2"
@onready var module_3: Node2D = $"Module Places/Module 3"
@onready var module_4: Node2D = $"Module Places/Module 4"

@onready var module_spaces: Array[Node2D] = [module_1, module_2, module_3, module_4]


var busy_blueprint_spots: Array[bool] = [false, false, false, false]
