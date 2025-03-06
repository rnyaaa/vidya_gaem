extends Node

signal dialog_started(npc_data)
signal dialog_ended()
signal dialog_advanced(new_text)

var is_dialog_active = false
var current_npc = null
var current_dialog_index = 0
var current_dialog_sequence = []
var interaction_distance = 10.0 

func check_npc_proximity(player_position, npcs):
	if is_dialog_active:
		return
		
	var closest_npc = null
	var closest_distance = interaction_distance + 1.0
	for npc in get_tree().get_nodes_in_group("npcs"):
		var distance = player_position.distance_to(npc.global_position)
		
		if distance < interaction_distance and distance < closest_distance:
			closest_npc = npc
			closest_distance = distance
			
		elif npc.interaction_prompt.visible:
			hide_interaction_prompt(npc)
	
	if closest_npc != null:
		show_interaction_prompt(closest_npc)
		
		if Input.is_action_just_pressed("ui_accept"):  
			start_dialog(closest_npc)

func show_interaction_prompt(npc):
	npc.interaction_prompt.visible = true

func hide_interaction_prompt(npc):
	npc.interaction_prompt.visible = false

func start_dialog(npc):
	if is_dialog_active:
		return
		
	current_npc = npc
	is_dialog_active = true
	current_dialog_index = 0
	current_dialog_sequence = npc.dialog_data.get_dialog_sequence()
	
	emit_signal("dialog_started", npc.dialog_data)
	display_current_dialog()

func end_dialog():
	is_dialog_active = false
	current_npc = null
	emit_signal("dialog_ended")

func advance_dialog():
	if not is_dialog_active:
		return
		
	current_dialog_index += 1
	
	if current_dialog_index >= current_dialog_sequence.size():
		end_dialog()
	else:
		display_current_dialog()

func display_current_dialog():
	var dialog_text = current_dialog_sequence[current_dialog_index]
	emit_signal("dialog_advanced", dialog_text)

func handle_dialog_input():
	if is_dialog_active and Input.is_action_just_pressed("ui_accept"):
		advance_dialog()
