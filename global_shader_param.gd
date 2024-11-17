extends WorldEnvironment

@export var fog_material: ShaderMaterial  # Reference to the FogVolume's material
@onready var fog_volume = $FogVolume      # Reference to FogVolume
@onready var camera = 'WorldEnvironment/Player/Camera3D'   # Reference to Camera3D
@onready var sun = $sun             # Reference to DirectionalLight3D

func _ready():
	if fog_material == null and fog_volume:
		fog_material = fog_volume.get_material() 
		if fog_material:
			print("Fog material found on FogVolume:", fog_material)
		else:
			print("Fog material not found on FogVolume.")

func _process(delta):
	if fog_material and camera and sun:
		fog_material.set_shader_parameter("camera_position", camera.global_transform.origin)
		var sun_direction = -sun.global_transform.basis.z.normalized()
		fog_material.set_shader_parameter("sun_direction", sun_direction)
		
