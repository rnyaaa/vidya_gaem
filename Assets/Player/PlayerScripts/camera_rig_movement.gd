extends Node3D

var time = 0
@export var amplitude: float = 0.01
@export var frequencyY: float = 0.4
@export var frequencyX: float = 0.23
@export var frequencyZ: float = 0.33
@export var freqMultiplier: float = 1
@export var shakeMultiplier: float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta
	
	rotation.x = sin(time * (frequencyX * freqMultiplier)) * (amplitude * shakeMultiplier)
	rotation.y = sin(time * (frequencyY * freqMultiplier)) * (amplitude * shakeMultiplier)
	rotation.z = sin(time * (frequencyZ * freqMultiplier)) * (amplitude * shakeMultiplier)
	
	position.y = sin(time * frequencyY) * (amplitude * shakeMultiplier)
	pass
