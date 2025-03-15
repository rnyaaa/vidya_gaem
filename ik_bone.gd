extends Marker3D

@export var length = 0.
@onready var mesh = $mesh

var end: Marker3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	end = Marker3D.new()
	end.position = position + Vector3(length, 0.0, 0.0)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	mesh.look_at(get_end())
	
func get_end():
	end.position = transform.basis.z.normalized() * length
	return end.position
