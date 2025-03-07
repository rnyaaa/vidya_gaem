extends RigidBody3D

signal diceThrown

var throw = 0
var check = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and throw == 0:
		set_freeze_enabled(false)
		
		apply_torque(randomTorque())
		apply_impulse(randomImpulse())
		throw = 1
		
		await get_tree().create_timer(1).timeout
		diceThrown.emit
		

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
	
#func completeStopCheck():
	#var stopCheck: Vector3
	#stopCheck = linear_velocity.round()
	#
	#if stopCheck.x == 0 and check == 0:
		#check = 1
		#completeStop.emit()
