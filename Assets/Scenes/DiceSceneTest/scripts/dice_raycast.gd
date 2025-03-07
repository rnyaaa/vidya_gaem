extends Node3D

signal scoreValue(index: int, amount: int)

var result: int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	scoreValue.emit(1, checkSide())
	pass

func checkSide():
	
	if $raycast_1.is_colliding():
		result = 1
	elif $raycast_2.is_colliding():
		result = 2
	elif $raycast_3.is_colliding():
		result = 3
	elif $raycast_4.is_colliding():
		result = 4
	elif $raycast_5.is_colliding():
		result = 5
	else:
		result = 6
	
	return result
