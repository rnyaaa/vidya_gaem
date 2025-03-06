extends Node3D

@onready var ground = $ground
@onready var pillar = $pillar
@onready var wall   = $wall
@onready var camera = $CharacterBody3D

const PIXEL_SIZE = 0.01
const SPRITE_HEIGHT = 32 * PIXEL_SIZE
const SPRITE_WIDTH = Vector3(1.0, 0.0, 1.0) * 128.0 * PIXEL_SIZE
const SPRITE_DEPTH = Vector3(1.0, 0.0, -1.0) * 75.0 * PIXEL_SIZE
const SPRITE_WIDTH_FRONT = Vector3(1.0, 0.0, -1.0) * 128.0 * PIXEL_SIZE
const SPRITE_DEPTH_FRONT = Vector3(1.0, 0.0, 1.0) * 75.0 * PIXEL_SIZE
const MAP_SIZE = 100
const NOISE_SCALE = 50

var tiles = []

var lightpos = []
var lightcolor = []
var lightsize = []

var blend_factor = 0.0
var texture = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var noise = FastNoiseLite.new()
	noise.seed = randi()

	for i in MAP_SIZE:
		for j in MAP_SIZE:
			var noiseval = noise.get_noise_2d(i * 20, j * 20)
			noiseval = noiseval*1.2
			noiseval = pow(noiseval, 6)
			var height = floor(noiseval * NOISE_SCALE) * SPRITE_HEIGHT * Vector3.UP
			var sidepos = (i * SPRITE_DEPTH) + (j * SPRITE_WIDTH / 2.0) + height
			var frontpos = (i * SPRITE_WIDTH_FRONT / 2.0) + (j * SPRITE_DEPTH_FRONT) + height
			
			var new
			if(floor(noiseval * NOISE_SCALE) > 2):
				new = pillar.duplicate()
			elif(floor(noiseval * NOISE_SCALE) > 0):
				new = wall.duplicate()
			else:
				new = ground.duplicate()
			add_child(new)
			new.position = frontpos
			
			for k in floor(noiseval * NOISE_SCALE):
				var under = new.duplicate()
				add_child(under)
				tiles.append({"node": under, "sidepos": sidepos - Vector3(0, k * SPRITE_HEIGHT, 0), "frontpos": frontpos - Vector3(0, k * SPRITE_HEIGHT, 0)})
			tiles.append({"node": new, "sidepos": sidepos, "frontpos": frontpos})
			

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	#var lightpos = []
	#var lightcolor = []
	#var lightsize = []
	#for child in get_children():
	#	if child is OmniLight3D:
	#		lightpos.append(child.position)
	#		lightcolor.append(child.get_correlated_color())
	#		lightsize.append(child.omni_range)
			
	#var light_count = lightpos.size()
	#var image = Image.create(light_count, 1, false, Image.FORMAT_RGBAF)
	#for i in range(light_count):
	#	var pos = lightpos[i]
	#	var color = lightcolor[i]
	#	var size = lightsize[i]
	#	
	#	var pixel = Color(pos.x, pos.y, pos.z, 1.0) 
	#	var nextpixel = Color(color.r, color.g, color.b, size)
	#	image.set_pixel(i*2, 0, pixel)
	#	image.set_pixel((i*2)+1, 0, nextpixel)

	#texture = ImageTexture.create_from_image(image)
	
	var angle = (camera.rotation.y)
	var blend_factor = abs(cos(2 * angle))
	for tile in tiles:
		tile["node"].position = lerp(tile["sidepos"], tile["frontpos"], blend_factor / 1000.0)
		tile["node"].position.y += cos(tile["node"].position.distance_to(camera.intersection_point) / 17.5) * 2.5
		#tile["node"].material_override().set_shader_param("light_texture", texture)
