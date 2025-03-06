extends Sprite3D

@export var bob_height: float = 0.2
@export var bob_speed: float = 2.0
@export var rotation_speed: float = 1.0

var initial_y: float
var time: float = 0.0

func _ready():
	initial_y = position.y
	visible = false

func _process(delta):
	if visible:
		time += delta
		position.y = initial_y + sin(time * bob_speed) * bob_height
		# rotate_y(rotation_speed * delta)
