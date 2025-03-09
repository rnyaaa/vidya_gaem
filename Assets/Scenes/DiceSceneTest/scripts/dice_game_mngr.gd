extends Node3D

signal DiceSum(sum: int, enemySum: int)
signal GameResult(gameResult: StringName)

@onready var dice_class: DiceClass = $Player/DiceClass
@onready var dice_class_2: DiceClass = $Player/DiceClass2
@onready var dice_class_3: DiceClass = $Player/DiceClass3
@onready var dice_class_4: DiceClass = $Player/DiceClass4
@onready var dice_class_5: DiceClass = $Player/DiceClass5
@onready var dice_class_6: DiceClass = $Player/DiceClass6

@onready var enemy_dice_class: EnemyDiceClass = $EnemyGambler/EnemyDiceClass
@onready var enemy_dice_class_2: EnemyDiceClass = $EnemyGambler/EnemyDiceClass
@onready var enemy_dice_class_3: EnemyDiceClass = $EnemyGambler/EnemyDiceClass3
@onready var enemy_dice_class_4: EnemyDiceClass = $EnemyGambler/EnemyDiceClass4
@onready var enemy_dice_class_5: EnemyDiceClass = $EnemyGambler/EnemyDiceClass5
@onready var enemy_dice_class_6: EnemyDiceClass = $EnemyGambler/EnemyDiceClass6

var dice1
var dice2
var dice3
var dice4
var dice5
var dice6
var sum: int

var enemy_dice1
var enemy_dice2
var enemy_dice3
var enemy_dice4
var enemy_dice5
var enemy_dice6
var enemySum: int

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
	
	if Input.is_action_just_pressed("Return"):
		get_tree().change_scene_to_file("res://test_map.tscn")
	
	if Input.is_action_just_pressed("ui_accept"):
		
		await get_tree().create_timer(3.5).timeout 
		
		checkSums()
		
		
		#setja summur i array her


func checkSums():
	dice1 = dice_class.DiceValue
	dice2 = dice_class_2.DiceValue
	dice3 = dice_class_3.DiceValue
	dice4 = dice_class_4.DiceValue
	dice5 = dice_class_5.DiceValue
	dice6 = dice_class_6.DiceValue
	
	sum = dice1+dice2+dice3+dice4+dice5+dice6
	
	enemy_dice1 = enemy_dice_class.EnemyDiceValue
	enemy_dice2 = enemy_dice_class_2.EnemyDiceValue
	enemy_dice3 = enemy_dice_class_3.EnemyDiceValue
	enemy_dice4 = enemy_dice_class_4.EnemyDiceValue
	enemy_dice5 = enemy_dice_class_5.EnemyDiceValue
	enemy_dice6 = enemy_dice_class_6.EnemyDiceValue
	
	enemySum = enemy_dice1+enemy_dice2+enemy_dice3+enemy_dice4+enemy_dice5+enemy_dice6
	
	if sum > enemySum:
		GameResult.emit("You won!")
	elif sum < enemySum:
		GameResult.emit("You lost :'-(")
	else:
		GameResult.emit("Draw!")
	DiceSum.emit(sum, enemySum)
	
