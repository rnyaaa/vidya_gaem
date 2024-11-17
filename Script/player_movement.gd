class_name my_input 

extends Camera3D

var velocity = Vector3(0., 0., 0.)
var move_speed = 2
var mouse_sensitivity = 0.01

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	set_process(true)

func _process(delta: float) -> void:
	if(Input.is_key_pressed(KEY_W)):
		velocity -= transform.basis.z * move_speed * delta
	if(Input.is_key_pressed(KEY_A)):
		velocity -= transform.basis.x * move_speed * delta
	if(Input.is_key_pressed(KEY_S)):
		velocity += transform.basis.z * move_speed * delta
	if(Input.is_key_pressed(KEY_D)):
		velocity += transform.basis.x * move_speed * delta
		
	position += velocity
	velocity *= 0.9
		
func _input(event):
	if event is InputEventMouseMotion:
		rotation.y = rotation.y - event.get_relative().x * mouse_sensitivity
		rotation.x = clamp(rotation.x - event.get_relative().y * mouse_sensitivity, -PI/2, PI/2)
			
			
