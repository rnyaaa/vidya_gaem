extends Marker3D
var bone: PackedScene = preload("res://IK_BONE.tscn")
@export var n_bones = 1
@export var bone_len = 0.5
@export var margin = 0.2
@export var max_iterations = 50
@export var incr = 0.2
@export var target: Vector3
@export var smoothing_factor: float = 0.05  # Lower = smoother but slower response

# Store previous bone transforms for smoothing
var prev_bone_positions = []
var prev_bone_rotations = []
var bones = []
var should_try = true
var curr_index = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var prev_end = null
	for i in range(n_bones+1):
		var newbone = bone.instantiate()
		add_child(newbone)
		if prev_end == null:
			newbone.position = Vector3.ZERO  # Start at origin of this node
		else:
			newbone.position = prev_end - position  # Position relative to parent
		newbone.length = bone_len
		prev_end = newbone.position + Vector3(0, 0, -bone_len)  # Assuming bones point along -Z
		bones.append(newbone)
	
	# Initialize smoothing arrays
	prev_bone_positions = []
	prev_bone_rotations = []
	for bone in bones:
		prev_bone_positions.append(bone.global_position)
		prev_bone_rotations.append(bone.global_transform.basis)
		
	# Initial bone chain positioning
	update_bone_chain()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Calculate smoothing based on delta to maintain consistent smoothing regardless of framerate
	var smooth_factor = clamp(1.0 - pow(1.0 - smoothing_factor, delta * 60.0), 0.001, 1.0)
	
	# Use FABRIK algorithm with smoothing
	fabrik_solve(target, smooth_factor)

# FABRIK (Forward And Backward Reaching Inverse Kinematics) implementation with smoothing
func fabrik_solve(target_pos: Vector3, smooth_factor: float) -> void:
	# Skip if we're already close enough
	var end_effector = get_end_effector_position()
	if end_effector.distance_to(target_pos) <= margin:
		return

	# Store original positions
	var original_positions = []
	for bone in bones:
		original_positions.append(bone.global_position)
	
	# Add end effector position
	var last_bone = bones[bones.size() - 1]
	original_positions.append(last_bone.global_position - last_bone.global_transform.basis.z.normalized() * bone_len)
	
	# Store original rotations
	var original_rotations = []
	for bone in bones:
		original_rotations.append(bone.global_transform.basis)
	
	# Max chain length check
	var total_length = bone_len * n_bones
	var distance_to_target = original_positions[0].distance_to(target_pos)
	
	# Create target positions array to hold our solution
	var target_positions = original_positions.duplicate()
	var target_forward_dirs = []
	
	for i in range(bones.size()):
		target_forward_dirs.append(Vector3.ZERO)
	
	if distance_to_target > total_length:
		# Target is too far - extend toward target as much as possible
		var dir_to_target = original_positions[0].direction_to(target_pos)
		for i in range(1, bones.size() + 1):
			if i < original_positions.size():
				target_positions[i] = original_positions[0] + dir_to_target * bone_len * i
	else:
		# Target is reachable - iterate to find solution
		var iterations = 0
		var tolerance = 0.001
		var positions = original_positions.duplicate()
		
		while iterations < max_iterations:
			# --- Backward pass (from target to root) ---
			positions[positions.size() - 1] = target_pos
			
			for i in range(positions.size() - 2, -1, -1):
				var direction = positions[i].direction_to(positions[i + 1])
				positions[i] = positions[i + 1] - direction * bone_len
			
			# --- Forward pass (from root to target) ---
			positions[0] = original_positions[0]  # Root doesn't move
			
			for i in range(0, positions.size() - 1):
				var direction = positions[i].direction_to(positions[i + 1])
				positions[i + 1] = positions[i] + direction * bone_len
			
			# Check if end effector is close enough to target
			if positions[positions.size() - 1].distance_to(target_pos) < tolerance:
				break
				
			iterations += 1
		
		# Store the solution
		target_positions = positions
	
	# Calculate forward directions
	for i in range(bones.size()):
		if i < bones.size() - 1:
			target_forward_dirs[i] = target_positions[i].direction_to(target_positions[i + 1])
		else:
			# Important: For the last bone, point directly to the target, not the calculated end effector
			target_forward_dirs[i] = target_positions[i].direction_to(target_pos)
	
	# Apply positions and rotations to bones with consistent Y constraints
	for i in range(bones.size()):
		# Apply Y constraint if needed (prevent bones from going below ground)
		if target_positions[i].y < 0.5:
			target_positions[i].y = 0.5
		
		# Apply smoothed position with reduced smoothing (let the manager handle most smoothing)
		var actual_smooth_factor = smooth_factor * 0.5
		var smoothed_position = prev_bone_positions[i].lerp(target_positions[i], actual_smooth_factor)
		bones[i].global_position = smoothed_position
		prev_bone_positions[i] = smoothed_position
		
		# Align and smooth rotation
		if target_forward_dirs[i].length() > 0.001:
			# Create target basis
			var target_basis = create_aligned_basis(target_forward_dirs[i])
			
			# Smooth rotation (using quaternions for better interpolation)
			var current_quat = Quaternion(prev_bone_rotations[i])
			var target_quat = Quaternion(target_basis)
			var smoothed_quat = current_quat.slerp(target_quat, actual_smooth_factor)
			var smoothed_basis = Basis(smoothed_quat)
			
			bones[i].global_transform.basis = smoothed_basis
			prev_bone_rotations[i] = smoothed_basis

# Create a basis aligned to point in the given direction (along -Z axis)
func create_aligned_basis(direction: Vector3) -> Basis:
	direction = direction.normalized()
	
	# Create a rotation that aligns the bone's -Z axis with the target direction
	var y_axis = Vector3(0, 1, 0)  # Default up direction
	
	# If direction is too close to up/down, use a different up vector
	if abs(direction.dot(y_axis)) > 0.99:
		y_axis = Vector3(1, 0, 0)
	
	var x_axis = y_axis.cross(direction).normalized()
	y_axis = direction.cross(x_axis).normalized()
	
	# Return a basis with -Z pointing in the desired direction
	return Basis(-x_axis, y_axis, -direction)

# Update positions of all bones in chain - used for initialization
func update_bone_chain() -> void:
	# Clear arrays first to avoid duplicates
	prev_bone_positions = []
	prev_bone_rotations = []
	
	for i in range(1, bones.size()):
		var parent_bone = bones[i-1]
		var child_bone = bones[i]
		
		# Calculate end position of parent bone
		var parent_end = parent_bone.global_position - parent_bone.global_transform.basis.z.normalized() * bone_len
		
		# Position child at parent's end
		child_bone.global_position = parent_end
		child_bone.global_position.y = max(0.5, child_bone.global_position.y)
	
	# Initialize smoothing arrays
	for bone in bones:
		prev_bone_positions.append(bone.global_position)
		prev_bone_rotations.append(bone.global_transform.basis)
		
# Get position of the end effector (end of last bone)
func get_end_effector_position() -> Vector3:
	var last_bone = bones[bones.size() - 1]
	return last_bone.global_position - last_bone.global_transform.basis.z.normalized() * bone_len
