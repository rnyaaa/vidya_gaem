extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Restart"):
		print("restart!")
		get_tree().reload_current_scene()
	
	if Input.is_action_just_pressed("ui_cancel"):
		print("quit!")
		await get_tree().create_timer(0.1).timeout
		get_tree().quit(0)
		
	if Input.is_action_just_pressed("Fullscreen"):
		var fullscreenToggle: bool = false
		
		if fullscreenToggle == false:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			fullscreenToggle = true
		if fullscreenToggle == true:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			fullscreenToggle = false
		print(fullscreenToggle)

	if Input.is_action_pressed("Controls"):
		$UI/Controls.visible = true
	else:
		$UI/Controls.visible = false
