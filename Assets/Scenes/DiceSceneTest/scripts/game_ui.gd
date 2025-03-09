extends Node

@onready var score_label: Label = $PlayerScoreLabel/ColorRect/Label
@onready var enemy_label: Label = $EnemyScoreLabel/ColorRect/Label
@onready var result_label: Label = $Result/ColorRect/Label
@onready var result_color_rect: ColorRect = $Result/ColorRect

var scoreAmount = 0
var enemyScoreAmount = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	result_color_rect.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	score_label.text = "Your score:\n" + str(scoreAmount)
	enemy_label.text = "Enemy score:\n" + str(enemyScoreAmount)
	pass


func _on_dice_game_dice_sum(sum: int, enemySum: int) -> void:
	scoreAmount = sum
	enemyScoreAmount = enemySum


func _on_dice_game_game_result(gameResult: StringName) -> void:
	result_color_rect.visible = true
	result_label.text = str(gameResult)
