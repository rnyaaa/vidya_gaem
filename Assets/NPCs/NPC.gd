extends CharacterBody3D 

@export var npc_name: String = "NPC"
@export var portrait_texture: Texture2D
@export_multiline var dialog_lines: Array[String] = []

@onready var interaction_prompt = $InteractionPrompt

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

func _ready():
	dialog_data = DialogData.new(npc_name, portrait_texture, dialog_lines)
	print(dialog_data.dialog_lines)
	add_to_group("npcs")
	
	if has_node("InteractionPrompt"):
		get_node("InteractionPrompt").visible = false
