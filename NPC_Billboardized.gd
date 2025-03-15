extends Node3D

@export var npc_name: String = "NPC"
@export var portrait_texture: Texture2D
@export_multiline var dialog_lines: Array[String] = []

@onready var interaction_prompt = $InteractionPrompt
@export var player: PackedScene             # Reference to player node
@onready var camera: Camera3D = $"../../playerbox/CameraRig/Camera3D"

@export var mesh: PackedScene
@onready var mesh_billboardizer = $Billboardizer
@onready var mesh_sprite = $MeshSprite

class DialogData:
	var npc_name: String
	var portrait: Texture2D
	var dialog_lines: Array[String]
	
	func _init(p_name, p_portrait, p_lines):
		npc_name = p_name
		portrait = p_portrait
		dialog_lines = p_lines
	
	func get_dialog_sequence():
		return dialog_lines

var dialog_data: DialogData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dialog_data = DialogData.new(npc_name, portrait_texture, dialog_lines)
	#print(dialog_data.dialog_lines)
	add_to_group("npcs")
	
	if has_node("InteractionPrompt"):
		get_node("InteractionPrompt").visible = false
		
	setup_billboardizers()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_billboards(delta)

func setup_billboardizers() -> void:
	var mesh_scene = PackedScene.new()
	var mesh_instance = mesh.instantiate()
	mesh_billboardizer.input_mesh = mesh_scene

func update_billboards(delta: float) -> void:
	var camera_forward = -camera.global_transform.basis.z.normalized()
	var mesh_forward = global_transform.basis.z.normalized()
	#distance_to_camera = global_transform.origin.distance_to(camera.global_transform.origin)
	var tex = await mesh_billboardizer.get_texture(mesh_forward, camera_forward)
	mesh_sprite.texture = tex
