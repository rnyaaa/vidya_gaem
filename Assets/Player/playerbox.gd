extends GeometryInstance3D

# Movement speed
@export var speed: float = 5.0
# Rotation speed in degrees
@export var rotation_speed: float = 15.0
# Reference to the animated sprite
@export var animated_sprite: AnimatedSprite3D

@onready var dialog_system = get_node("/root/DialogSystem")

# Available animation names
const ANIM_NORTH = "walk_north"
const ANIM_NORTHWEST = "walk_northwest" 
const ANIM_WEST = "walk_west"
const ANIM_SOUTHWEST = "walk_southwest"

# Track the last played animation for idle state
var last_direction := Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Ensure required nodes are assigned
	if animated_sprite == null:
		push_warning("AnimatedSprite3D not assigned to character controller")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var direction = Vector3.ZERO
	
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	if input_dir.length() < 0.1:
		if animated_sprite and animated_sprite.is_playing:
			animated_sprite.stop()
	else:
		last_direction = input_dir
		play_directional_animation(input_dir)
	
	if direction != Vector3.ZERO:
		direction = transform.basis * direction
		position += direction * speed * delta
	
	if Input.is_action_just_pressed("rotate_left"):
		rotate_y(deg_to_rad(15))
	if Input.is_action_just_pressed("rotate_right"):
		rotate_y(deg_to_rad(-15))
		
	var npcs = get_tree().get_nodes_in_group("npcs")
	dialog_system.check_npc_proximity(global_position, npcs)
	
	if Input.is_action_just_pressed("ui_accept"):  
		dialog_system.advance_dialog()


func play_directional_animation(input_dir: Vector2) -> void:
	if not animated_sprite:
		return
		
	var angle = rad_to_deg(atan2(input_dir.y, input_dir.x))
	if angle < 0:
		angle += 360
	
	var anim_name = ""
	var flip_h = false
	
	# WEST
	if angle > 225 and angle <= 315:  # North-West quadrant
		if angle > 225 and angle <= 270:
			anim_name = ANIM_SOUTHWEST
			flip_h = true
		else:  # 270-315
			anim_name = ANIM_NORTHWEST
			flip_h = false
	elif angle > 135 and angle <= 225:  # South-West quadrant
		if angle > 180:
			anim_name = ANIM_WEST
			flip_h = false
		else:  # 135-180
			anim_name = ANIM_SOUTHWEST
			flip_h = false
			
	# EAST
	elif angle > 45 and angle <= 135:  # South-East quadrant
		if angle > 90:
			anim_name = ANIM_SOUTHWEST
			flip_h = true
		else:  # 45-90
			anim_name = ANIM_WEST
			flip_h = true
	elif angle > 315 or angle <= 45:  # North-East quadrant
		if angle > 315:
			anim_name = ANIM_NORTHWEST
			flip_h = true
		else:  # 0-45
			anim_name = ANIM_SOUTHWEST
			flip_h = true
	
	# NORTH AND SOUTH
	if (angle > 270 and angle <= 315) or (angle > 45 and angle <= 90):
		anim_name = ANIM_NORTH
		flip_h = (angle > 45 and angle <= 90)  # Flip if it's south
	
	if anim_name != "":
		animated_sprite.flip_h = flip_h
		# Play 
		if animated_sprite.animation != anim_name or not animated_sprite.is_playing:
			animated_sprite.play(anim_name)
