extends Node3D
@export var input_mesh: PackedScene
@onready var viewport = $SubViewport
@onready var camera = $SubViewport/Camera3D

# Dictionary to store images by angle pair (quantized to 15 degrees)
var angle_images = {}
var mesh_instance = null

# Quantization resolution in degrees
@export var angle_resolution: int = 15

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Instantiate the mesh and add it to the viewport
	if input_mesh:
		mesh_instance = input_mesh.instantiate()
		viewport.add_child(mesh_instance)
		#print("Instantiated mesh: ", mesh_instance.name)
		
		# Position mesh at the center of the viewport
		mesh_instance.position = Vector3.ZERO
		
		# Ensure camera is looking straight down at the mesh (standard position)
		camera.position = Vector3(0, 5, 0)
		camera.rotation = Vector3(-PI/2, 0, 0)  # -90 degrees around X axis (looking down)

# Function to get a texture based on camera position and forward vector
func get_texture(bone_forward: Vector3, camera_forward: Vector3) -> ImageTexture:
	# Normalize vectors to ensure consistent calculations
	bone_forward = bone_forward.normalized()
	camera_forward = camera_forward.normalized()
	
	# Create a complete local coordinate system for the bone
	var bone_up = Vector3.UP
	if abs(bone_forward.dot(bone_up)) > 0.9:
		bone_up = Vector3.BACK
	
	var bone_right = bone_up.cross(bone_forward).normalized()
	bone_up = bone_forward.cross(bone_right).normalized()
	
	# Project camera_forward onto the bone's local coordinate system
	var local_camera_dir = Vector3(
		camera_forward.dot(bone_right),
		camera_forward.dot(bone_up),
		camera_forward.dot(bone_forward)
	)
	
	# Calculate spherical angles in this system
	var azimuth = rad_to_deg(atan2(local_camera_dir.x, local_camera_dir.z))
	var elevation = rad_to_deg(asin(clamp(local_camera_dir.y, -1.0, 1.0)))
	
	# Invert azimuth because we want the opposite view 
	# (what the camera sees of the bone, not what the bone sees of the camera)
	azimuth = int(azimuth + 180) % 360
	
	# Ensure azimuth is in 0-360 range
	while azimuth < 0:
		azimuth += 360
	
	# Quantize angles
	var quantized_azimuth = round(azimuth / angle_resolution) * angle_resolution
	var quantized_elevation = round(elevation / angle_resolution) * angle_resolution
	
	# Create angle key
	var angle_key = str(int(quantized_azimuth)) + "_" + str(int(quantized_elevation))
	
	# Debug
	#print("Bone forward: ", bone_forward)
	#print("Camera forward: ", camera_forward)
	#print("Azimuth: ", azimuth, " -> ", quantized_azimuth)
	#print("Elevation: ", elevation, " -> ", quantized_elevation)
	#print("Angle key: ", angle_key)
	
	# Get or render texture
	if angle_images.has(angle_key):
		return angle_images[angle_key]
	
	# For rendering new images, we still need position info, but we can use dummy values
	# since we're just setting up a scene to render from different angles
	return await render_new_image(quantized_azimuth, quantized_elevation, camera_forward, bone_forward)

# Calculate angles relative to the bone's forward vector
func calculate_relative_angles(camera_dir: Vector3, forward_vec: Vector3) -> Vector2:
	# Create a coordinate system based on the bone's forward vector
	var bone_forward = forward_vec.normalized()
	var bone_up = Vector3.UP
	
	# If bone_forward is too aligned with UP, choose a different UP
	if abs(bone_forward.dot(bone_up)) > 0.9:
		bone_up = Vector3.BACK
	
	var bone_right = bone_up.cross(bone_forward).normalized()
	bone_up = bone_forward.cross(bone_right).normalized()
	
	# Transform camera_dir to this local coordinate system
	var local_camera_dir = Vector3(
		camera_dir.dot(bone_right),
		camera_dir.dot(bone_up),
		camera_dir.dot(bone_forward)
	)
	
	# Now calculate spherical coordinates in this system
	var azimuth = rad_to_deg(atan2(local_camera_dir.x, local_camera_dir.z))
	if azimuth < 0:
		azimuth += 360
		
	var elevation = rad_to_deg(asin(clamp(local_camera_dir.y, -1.0, 1.0)))
	
	return Vector2(azimuth, elevation)

# Render a new image by orienting the mesh correctly relative to the camera
 # Render a new image by orienting the mesh correctly relative to the camera
# Render a new image by considering both the object's orientation and camera's view
func render_new_image(azimuth: float, elevation: float, camera_dir: Vector3, bone_forward: Vector3) -> ImageTexture:
	if not mesh_instance:
		return null
	
	# Reset mesh rotation
	mesh_instance.transform = Transform3D.IDENTITY
	mesh_instance.position = Vector3.ZERO
	
	# For billboards, we need to rotate the mesh AWAY from the camera view
	# This is because in-game, the billboard will rotate TO face the camera
	
	# Convert the camera viewing angles to the mesh rotation
	# We add 180 to azimuth to get the opposite direction
	var mesh_azimuth = -(azimuth)
	if mesh_azimuth < 0:
		mesh_azimuth += 360
	
	# The elevation needs to be inverted
	var mesh_elevation = -elevation
	
	# Convert to radians
	var azimuth_rad = deg_to_rad(mesh_azimuth)
	var elevation_rad = deg_to_rad(mesh_elevation)
	
	# First rotate around Y axis for azimuth
	mesh_instance.rotate_y(azimuth_rad)
	
	# Then rotate around X axis for elevation
	mesh_instance.rotate_x(elevation_rad)
	
	# Keep camera static, looking at origin
	camera.position = Vector3(0, 0, 5)  # Fixed distance
	camera.look_at(Vector3.ZERO, Vector3.UP)
	
	# Wait for the viewport to render
	await get_tree().process_frame
	
	# Capture the viewport texture
	var img = viewport.get_texture().get_image()
	
	# Create ImageTexture from the captured image
	var tex = ImageTexture.create_from_image(img)
	
	# Cache the result
	var angle_key = str(int(azimuth)) + "_" + str(int(elevation))
	angle_images[angle_key] = tex
	
	#print("Rendered new image for angle: ", angle_key)
	
	return tex
	
# Function to clear the cache if needed
func clear_cache() -> void:
	angle_images.clear()
	#print("Image cache cleared")

# Function to prerender all angles (optional)
func prerender_all_angles() -> void:
	#print("Starting prerendering of all angles...")
	var camera_pos = Vector3(0, 0, 5)  # Example camera position
	
	# Loop through all possible azimuth and elevation combinations
	for azimuth in range(0, 360, angle_resolution):
		for elevation in range(-90, 91, angle_resolution):
			# Skip extreme elevation angles if desired
			if abs(elevation) > 80:
				continue
				
			# Convert spherical coordinates to cartesian (forward vector)
			var azimuth_rad = deg_to_rad(azimuth)
			var elevation_rad = deg_to_rad(elevation)
			
			var forward_vec = Vector3(
				sin(azimuth_rad) * cos(elevation_rad),
				sin(elevation_rad),
				cos(azimuth_rad) * cos(elevation_rad)
			)
			
			var _tex = await get_texture(camera_pos, forward_vec)
			
			# Add a small delay to prevent freezing the editor
			await get_tree().create_timer(0.01).timeout
	#	
	#print("Prerendering complete. Cached ", angle_images.size(), " angles.")
