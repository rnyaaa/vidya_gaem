extends CanvasLayer

@onready var dialog_box = $Container/DialogBox
@onready var portrait = $Container/Portrait
@onready var npc_name_label = $Container/NPCName
@onready var dialog_text = $Container/DialogText
@onready var prompt_indicator = $Container/PromptIndicator

@export var fade_in_duration: float = 0.5
@export var fade_out_duration: float = 0.3

var tween: Tween

func _ready():
	# Hide UI elements initially
	dialog_box.modulate.a = 0
	portrait.modulate.a = 0
	npc_name_label.modulate.a = 0
	dialog_text.modulate.a = 0
	prompt_indicator.modulate.a = 0
	
	set_process(false)
	set_visible(false)
	
	# Connect to dialog system signals
	var dialog_system = get_node("/root/DialogSystem")  # Assumes DialogSystem is an autoload
	dialog_system.connect("dialog_started", Callable(self, "_on_dialog_started"))
	dialog_system.connect("dialog_ended", Callable(self, "_on_dialog_ended"))
	dialog_system.connect("dialog_advanced", Callable(self, "_on_dialog_advanced"))

func _process(_delta):
	# Optional: Add animation to the prompt indicator
	prompt_indicator.position.y = 16 + sin(Time.get_ticks_msec() / 200.0) * 4

func _on_dialog_started(npc_data):
	# Set up UI with NPC data
	npc_name_label.text = npc_data.npc_name
	portrait.texture = npc_data.portrait
	
	# Show the UI
	set_visible(true)
	set_process(true)
	
	# Animate the UI elements fading in
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(dialog_box, "modulate:a", 1.0, fade_in_duration)
	tween.tween_property(portrait, "modulate:a", 1.0, fade_in_duration)
	tween.tween_property(npc_name_label, "modulate:a", 1.0, fade_in_duration)
	tween.tween_property(dialog_text, "modulate:a", 1.0, fade_in_duration)
	tween.tween_property(prompt_indicator, "modulate:a", 1.0, fade_in_duration)

func _on_dialog_ended():
	# Animate the UI elements fading out
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(dialog_box, "modulate:a", 0.0, fade_out_duration)
	tween.tween_property(portrait, "modulate:a", 0.0, fade_out_duration)
	tween.tween_property(npc_name_label, "modulate:a", 0.0, fade_out_duration)
	tween.tween_property(dialog_text, "modulate:a", 0.0, fade_out_duration)
	tween.tween_property(prompt_indicator, "modulate:a", 0.0, fade_out_duration)
	
	# Hide and disable processing once the fade out is complete
	tween.tween_callback(Callable(self, "set_visible").bind(false))
	tween.tween_callback(Callable(self, "set_process").bind(false))

func _on_dialog_advanced(new_text):
	dialog_text.text = new_text
