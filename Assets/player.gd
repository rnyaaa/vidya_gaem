extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var mouse_sensitivity = 0.01

@onready var camera = $Camera3D

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity().y * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var cam_forward = -camera.transform.basis.z.normalized()  # Forward vector.
	var cam_right   = camera.transform.basis.x.normalized()    # Right vector.

	var input_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	var direction = (cam_forward * input_vector.y) + (cam_right * input_vector.x)
	direction = direction.normalized()  # Normalize to maintain consistent speed.

	if direction != Vector3.ZERO:
		velocity.z =  cam_right.x * SPEED
		velocity.x = -cam_forward.z * SPEED
	else:
		velocity.x = move_toward(direction.x, 0, SPEED * delta)
		velocity.z = move_toward(direction.z, 0, SPEED * delta)
	move_and_slide()

func _input(event):
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * mouse_sensitivity
		camera.rotation.x = clamp(camera.rotation.x - event.relative.y * mouse_sensitivity, -PI / 2, PI / 2)
