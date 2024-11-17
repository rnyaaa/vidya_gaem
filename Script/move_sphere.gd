extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var elapsed_time = 0.
var dist_travelled = 0.
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	elapsed_time += delta
	position.y += sin(elapsed_time / 2.) * 0.002
	var totravel = 0
	if((int(elapsed_time) % 20) > 17 && dist_travelled < PI):
		totravel = (((elapsed_time - 17.) /3.) * PI) / 180.
		dist_travelled += sin(totravel)
		rotation.y += totravel
	elif((int(elapsed_time) % 20) > 3 && (int(elapsed_time)) < 6 && dist_travelled < PI):
		totravel = ((elapsed_time /3.) * PI) / 180.
		dist_travelled += sin(totravel)
		rotation.y -= totravel
	else:
		dist_travelled = 0.
	
