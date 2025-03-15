extends Node3D

var startPos: Vector3
var updatedPos: Vector3
@export var roamRange: int = 2
@export var roamIntervalFrames: int = 360
var randomizedVector: Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	startPos = global_position
	print(startPos)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:	
	updatedPos = startPos + randomizedVector
	global_position = global_position.lerp(updatedPos, delta * 4)
	
	if Engine.get_frames_drawn() % roamIntervalFrames == 0:
		randomDir()
	pass

func randomDir():
	randomizedVector.x = randf_range(-roamRange,roamRange)
	randomizedVector.z = randf_range(-roamRange,roamRange)
	
