extends Node3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_dice_game_area_check_test_area_entered(area: Area3D) -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/DiceSceneTest/scenes/dices2.tscn")
