extends CharacterBody3D
class_name Player

# Movement speed
@export var speed: float = 15.0
@export var sprintMult: float = 1.5
# Rotation speed in degrees
@export var rotation_speed: float = 15.0
@export var gravity: float = 9.8

@onready var dialog_system = get_node("/root/DialogSystem")

var camRotationCounter: int

# Track the last played animation for idle state
var last_direction := Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var direction = Vector3.ZERO
	
	velocity *= Vector3.ZERO 
	
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
	direction.y += -gravity
	
	#Movement functionality
	if direction != Vector3.ZERO:
		direction = transform.basis * direction
		
	if Input.is_action_pressed("Sprint") == false:
		velocity += direction * speed * delta
	#Sprinting functionality
	else:
		velocity += direction * (speed * sprintMult) * delta
	
	if Input.is_action_pressed("rotate_left"):
		cameraRotation("rotate_left")
	elif Input.is_action_pressed("rotate_right"):
		cameraRotation("rotate_right")
	
	var npcs = get_tree().get_nodes_in_group("npcs")
	dialog_system.check_npc_proximity(global_position, npcs)

	if Input.is_action_just_pressed("ui_accept"):  
		dialog_system.advance_dialog()
	move_and_slide()

func cameraRotation(RotationDir):
	camRotationCounter += 1 #make framerate independant
	#make rotation faster the longer held
	if camRotationCounter >= 10:
		if RotationDir == "rotate_left":
			rotate_y(deg_to_rad(15))
		if RotationDir == "rotate_right":
			rotate_y(deg_to_rad(-15))
		camRotationCounter = 0
