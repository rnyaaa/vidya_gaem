extends Node3D
# Called when the node enters the scene tree for the first time.
var playerCheck: bool = false

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and playerCheck:
		get_tree().change_scene_to_file("res://Assets/Scenes/DiceSceneTest/scenes/dices2.tscn")

func _on_dice_game_area_check_test_body_entered(body: Node3D) -> void:
	playerCheck = true


func _on_dice_game_area_check_test_body_exited(body: Node3D) -> void:
	playerCheck = false
