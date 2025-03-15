extends Node3D

# Target behavior configuration
@export var detection_range: float = 10.0       # Distance to detect player
@export var follow_radius: float = 1.5          # How far targets can move from player
@export var wander_radius: float = 15.0          # How far targets can move when not following
@export var movement_speed: float = 2.0         # How fast targets move
@export var speed_variation: float = 0.5        # Random speed variation per arm
@export var target_change_time: float = 3.0     # Base time between picking new targets
@export var time_variation: float = 1.0         # Random time variation
@export var smoothing_factor: float = 0.95      # Higher = smoother transitions (0-1)
var old_target_change_time = target_change_time
var old_smoothing_factor = smoothing_factor
var old_movement_speed = movement_speed
# Node references
@export var player: PackedScene		# Reference to player node
@onready var camera: Camera3D = $"../playerbox/CameraRig/Camera3D"
@onready var head_node = $IK_HEAD
@onready var target_node = $target

# Arm and target management
var arms = []
var arm_targets = []                           # Current target for each arm
var arm_new_targets = []                       # Next position for each arm
var arm_target_timers = []                     # Timer for each arm
var arm_speeds = []                            # Speed for each arm
var is_following_player: bool = false          # Track if we're following player

# Billboardizer references
@export var arm_1: PackedScene = preload("res://Assets/NPCs/IK_NPC/Skel_Model/up_hand.fbx")
@export var arm_2: PackedScene = preload("res://Assets/NPCs/IK_NPC/Skel_Model/lo_hand.fbx")
@export var end: PackedScene = preload("res://Assets/NPCs/IK_NPC/Skel_Model/hand.fbx")
@export var head_scene: PackedScene = preload("res://Assets/NPCs/IK_NPC/Skel_Model/skull.fbx")

@onready var arm_1_billboardizer = $arm_1_billboardizer
@onready var arm_2_billboardizer = $arm_2_billboardizer
@onready var hand_billboardizer = $hand_billboardizer
@onready var head_billboardizer = $head_billboardizer

# Debugging - visualize targets
var target_nodes = []
var debug_mode = false  # Set to true to see visual targets

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Setup billboardizers
	setup_billboardizers()
	
	# Find all IK_ARM nodes
	for child in get_children():
		if child.name.contains("IK_ARM"):
			arms.append(child)
	
	# Initialize target data structures for each arm
	for i in range(arms.size()):
		# Start with a position near the NPC
		var initial_pos = global_position + Vector3(randf_range(-1, 1), randf_range(1, 2), randf_range(-1, 1))
		arm_targets.append(initial_pos)
		arm_new_targets.append(initial_pos)
		
		# Stagger timers so arms don't all change targets at once
		arm_target_timers.append(randf_range(0, target_change_time))
		
		# Give each arm slightly different movement speed
		arm_speeds.append(movement_speed + randf_range(-speed_variation, speed_variation))
		
		# Set initial targets
		arms[i].target = initial_pos
		
		# Create debug nodes if needed
		if debug_mode:
			var target_mesh = MeshInstance3D.new()
			target_mesh.mesh = SphereMesh.new()
			target_mesh.mesh.radius = 0.1
			target_mesh.mesh.height = 0.2
			add_child(target_mesh)
			target_mesh.global_position = initial_pos
			target_nodes.append(target_mesh)

# Setup billboardizers with their input meshes
func setup_billboardizers() -> void:
	var arm1_scene = PackedScene.new()
	var arm1_instance = arm_1.instantiate()
	arm_1_billboardizer.input_mesh = arm1_scene
	
	var arm2_scene = PackedScene.new()
	var arm2_instance = arm_2.instantiate()
	arm_2_billboardizer.input_mesh = arm2_scene
	
	var hand_scene = PackedScene.new()
	var hand_instance = end.instantiate()
	hand_billboardizer.input_mesh = hand_scene
	
	var skull_scene = PackedScene.new()
	var skull_instance = head_scene.instantiate()
	head_billboardizer.input_mesh = skull_scene

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Check if player is in range
	var was_following = is_following_player
	is_following_player = player != null and position.distance_to(player.global_position) < detection_range
	
	# If we just started or stopped following, reset target timers
	if was_following != is_following_player:
		for i in range(arm_target_timers.size()):
			arm_target_timers[i] = randf_range(0, target_change_time * 0.5)
	
	# Process each arm's target and movement
	for i in range(arms.size()):
		# Update timer
		arm_target_timers[i] -= delta
		
		# Time to pick a new random target?
		if arm_target_timers[i] <= 0:
			choose_new_target_for_arm(i)
			
			# Reset timer with some variation
			var time_modifier = 1.0 if is_following_player else 2.0
			arm_target_timers[i] = (target_change_time + randf_range(-time_variation, time_variation)) / time_modifier
		
		# Smoothly move current target toward the new target
		update_arm_target_position(i, delta)
		
		# Update the arm's IK target
		arms[i].target = arm_targets[i]
		
		# Update debug visualization
		if debug_mode and i < target_nodes.size():
			target_nodes[i].global_position = arm_targets[i]
	
	# Make the main body look at the average of all arm targets or the player
	update_body_orientation()
	
	# Update billboards for all arms and bones
	update_billboards(delta)

# Choose a new target position for an arm
func choose_new_target_for_arm(arm_index: int) -> void:
	if is_following_player:
		target_change_time = 0.1
		smoothing_factor = 0
		movement_speed = 20.0
		# Use player as the base position with some randomness
		var random_offset = Vector3(
			randf_range(-follow_radius, follow_radius),
			randf_range(0.5, follow_radius * 1.5),  # Keep above ground
			randf_range(-follow_radius, follow_radius)
		)
		arm_new_targets[arm_index] = player.global_position + random_offset
	else:
		target_change_time = old_target_change_time
		smoothing_factor = old_smoothing_factor
		movement_speed *= old_movement_speed
		# Use current position as base, then add random offset
		var random_offset = Vector3(
			randf_range(-wander_radius, wander_radius),
			randf_range(0.5, wander_radius),  # Keep above ground
			randf_range(-wander_radius, wander_radius)
		)
		arm_new_targets[arm_index] = global_position + random_offset
	
	# Keep target above ground and not too high
	arm_new_targets[arm_index].y = clamp(arm_new_targets[arm_index].y, 0.5, 3.0)
	
	# Keep target within reasonable distance from body
	var max_distance = 10.0  # Maximum distance from body
	if arm_new_targets[arm_index].distance_to(global_position) > max_distance:
		var dir = (arm_new_targets[arm_index] - global_position).normalized()
		arm_new_targets[arm_index] = global_position + dir * max_distance

# Update the current target position for an arm with smooth interpolation
func update_arm_target_position(arm_index: int, delta: float) -> void:
	# Calculate direction and distance
	var direction = arm_targets[arm_index].direction_to(arm_new_targets[arm_index])
	var distance = arm_targets[arm_index].distance_to(arm_new_targets[arm_index])
	
	# Apply speed with smoothing
	var move_distance = min(arm_speeds[arm_index] * delta, distance)
	
	# Calculate direct movement
	var direct_movement = direction * move_distance
	
	# Apply improved smoothing
	if distance > 0.05:  # Small threshold to prevent jitter
		# Determine actual smoothing based on whether we're following or wandering
		var actual_smoothing = smoothing_factor
		if is_following_player:
			actual_smoothing *= 0.7  # Less smoothing (faster response) when following player
		
		# Apply smoothed movement - using direct lerp for better control
		arm_targets[arm_index] = arm_targets[arm_index].lerp(
			arm_new_targets[arm_index], 
			delta * (1.0 - actual_smoothing) * 5.0  # Scale factor to make movement more noticeable
		)
	else:
		# We're very close to the target
		arm_targets[arm_index] = arm_new_targets[arm_index]

# Update the body orientation to face the average target or player
func update_body_orientation() -> void:
	# Calculate the look target
	var look_position
	
	if is_following_player:
		# When following player, primarily look at player
		look_position = player.global_position
	else:
		# When not following, look at the average of all arm targets
		look_position = Vector3.ZERO
		for target in arm_targets:
			look_position += target
		look_position /= arm_targets.size()
	
	# Look at the calculated position
	look_at(look_position)

# Update all billboards for arms and head
func update_billboards(delta: float) -> void:
	var camera_forward = -camera.global_transform.basis.z.normalized()
	
	# Update arm billboards
	for arm_idx in range(arms.size()):
		var arm = arms[arm_idx]
		
		for bone_idx in range(arm.bones.size()):
			# Get bone data
			var bone = arm.bones[bone_idx]
			var bone_forward = bone.global_transform.basis.z.normalized()
			var distance_to_camera = bone.global_transform.origin.distance_to(camera.global_transform.origin)
			var scale_factor = calculate_scale_factor(distance_to_camera)
			
			# Choose texture based on bone position
			if bone_idx % 2 == 0:
				var texture = await arm_1_billboardizer.get_texture(bone_forward, camera_forward)
				bone.mesh.texture = texture
			else:
				var texture = await arm_2_billboardizer.get_texture(bone_forward, camera_forward)
				bone.mesh.texture = texture
			
			# Handle last bone (hand) specially
			if bone_idx == arm.bones.size() - 1:
				var texture = await hand_billboardizer.get_texture(bone_forward, camera_forward)
				bone.mesh.texture = texture
			
			# Apply scaling
			apply_texture_scale(bone.mesh, scale_factor)
	
	# Update head billboard
	var head_forward = global_transform.basis.z.normalized()
	head_forward.y = 0.0
	var head_distance = global_transform.origin.distance_to(camera.global_transform.origin)
	var head_scale_factor = calculate_scale_factor(head_distance)
	head_node.texture = await head_billboardizer.get_texture(head_forward, camera_forward)
	apply_texture_scale(head_node, head_scale_factor)

# Helper function to calculate scale based on distance
func calculate_scale_factor(distance: float) -> float:
	# Example scaling logic - adjust these values to suit your needs
	var base_scale = 1.0
	var min_scale = 0.5
	var max_scale = 2.0
	var distance_factor = 5.0  # Controls how quickly scale changes with distance
	
	# Inverse relationship - closer = larger texture
	var scale = base_scale * (distance_factor / max(distance, 1.0))
	
	# Clamp between min and max values
	return clamp(scale, min_scale, max_scale)

# Helper function to apply the scale to the texture/material
func apply_texture_scale(mesh_instance, scale_factor: float) -> void:
	# Scale the mesh itself
	mesh_instance.scale = Vector3(scale_factor, scale_factor, scale_factor)
