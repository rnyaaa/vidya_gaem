extends Node

@onready var score_label: Label = $scoreLabel/ColorRect/Label
var scoreAmount = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	score_label.text = "Score:" + str(scoreAmount)
	pass


func _on_dice_game_dice_sum(sum: int) -> void:
	scoreAmount = sum
