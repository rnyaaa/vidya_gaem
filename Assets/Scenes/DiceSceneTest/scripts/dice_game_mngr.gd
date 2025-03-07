extends Node3D

signal DiceSum(sum: int)

@onready var dice_class: DiceClass = $DiceClass
@onready var dice_class_2: DiceClass = $DiceClass2
@onready var dice_class_3: DiceClass = $DiceClass3
@onready var dice_class_4: DiceClass = $DiceClass4
@onready var dice_class_5: DiceClass = $DiceClass5
@onready var dice_class_6: DiceClass = $DiceClass6

var dice1
var dice2
var dice3
var dice4
var dice5
var dice6
var sum: int

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
		await get_tree().create_timer(3).timeout 
		dice1 = dice_class.DiceValue
		dice2 = dice_class_2.DiceValue
		dice3 = dice_class_3.DiceValue
		dice4 = dice_class_4.DiceValue
		dice5 = dice_class_5.DiceValue
		dice6 = dice_class_6.DiceValue
		
		sum = dice1+dice2+dice3+dice4+dice5+dice6
	
	DiceSum.emit(sum)
	
