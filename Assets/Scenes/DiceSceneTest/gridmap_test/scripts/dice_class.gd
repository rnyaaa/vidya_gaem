extends Node3D
class_name DiceClass

@onready var rigid_body_3d: RigidBody3D = $RigidBody3D
@onready var raycast_group: Node3D = $RigidBody3D/raycast_group
@onready var dice_model: Node3D = $RigidBody3D/dice_model

@export var DiceValue: int
var throw = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rigid_body_3d.set_freeze_enabled(true)
	dice_model.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and throw == 0:
		dice_model.visible = true
		
		rigid_body_3d.set_freeze_enabled(false)
		
		rigid_body_3d.apply_torque(randomTorque())
		
		rigid_body_3d.apply_impulse(randomImpulse())
		
		throw = 1
		
	DiceValue = raycast_group.checkSide()

func randomImpulse():
	var x = randf_range(0.1, 5) * -1
	var y = randf_range(0.1, 5)
	var z = randf_range(0.1, 5) * -1
	var direction = Vector3(x,y,z)
	print("impulse direction =", direction)
	return direction
	
func randomTorque():
	var x = randf_range(-20, 20)
	var y = randf_range(-20, 20)
	var z = randf_range(-20, 20)
	var torque = Vector3(x,y,z)
	print("torque =", torque)
	return torque
	
