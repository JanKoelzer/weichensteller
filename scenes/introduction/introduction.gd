extends VBoxContainer

@onready var rails: AbstractRails = %Rails
@onready var step_1_label: RichTextLabel = %Step1Label
@onready var step_2_label: RichTextLabel = %Step2Label
@onready var step_3_control: Control = %Step3Control
@onready var start_game_button: Button = %StartGameButton
@onready var try_again_button: Button = %TryAgainButton
@onready var score_label: Label = %Step3Control/GridContainer/ScoreLabel
@onready var errors_label: Label = %Step3Control/GridContainer/ErrorsLabel
@onready var trains: Node2D = %Rails/Trains

enum Steps { GREEN_MOVING_TO_SWITCH, GREEN_WAITING_FOR_SWITCH, GREEN_MOVING_OVER_SWITCH, RED_WAITING_FOR_SWITCH, RED_MOVING_OVER_SWITCH}
var step := Steps.GREEN_MOVING_TO_SWITCH:
	set(v):
		step = v
		match v:
			Steps.GREEN_MOVING_TO_SWITCH:
				handle_green_moving_to_switch()
			Steps.GREEN_WAITING_FOR_SWITCH:
				handle_green_waiting_for_switch()
			Steps.GREEN_MOVING_OVER_SWITCH:
				handle_green_moving_over_switch()
			Steps.RED_WAITING_FOR_SWITCH:
				handle_red_waiting_for_switch()
			Steps.RED_MOVING_OVER_SWITCH:
				handle_red_moving_over_switch()


func handle_green_moving_to_switch() -> void:
	rails.start_tutorial_train_1()
	await get_tree().create_timer(3).timeout
	step = Steps.GREEN_WAITING_FOR_SWITCH


func handle_green_waiting_for_switch() -> void:
	if switch_is_active:
		step = Steps.GREEN_MOVING_OVER_SWITCH
	else:
		trains.process_mode = Node.PROCESS_MODE_DISABLED
		blink(step_1_label)
		
		await rails.switch_changed
		step = Steps.GREEN_MOVING_OVER_SWITCH


func handle_green_moving_over_switch() -> void:
	trains.process_mode = Node.PROCESS_MODE_ALWAYS
	await get_tree().create_timer(1).timeout
	rails.start_tutorial_train_2()
	step_2_label.visibility_layer = 1
	await get_tree().create_timer(2.5).timeout
	step = Steps.RED_WAITING_FOR_SWITCH


func handle_red_waiting_for_switch() -> void:
	if not switch_is_active:
		step = Steps.RED_MOVING_OVER_SWITCH
	else:
		trains.process_mode = Node.PROCESS_MODE_DISABLED
		blink(step_2_label)
		await rails.switch_changed
		step = Steps.RED_MOVING_OVER_SWITCH
	
func handle_red_moving_over_switch() -> void:
	trains.process_mode = Node.PROCESS_MODE_ALWAYS
					
var switch_is_active := false

var score := 0:
	set(v):
		score = v
		score_label.text = str(v)	
		
var errors := 0:
	set(v):
		errors = v
		errors_label.text = str(v)


func _exit_tree() -> void:
	BackgroundMovement.movement_enabled = true

func start_tutorial() -> void:
	BackgroundMovement.movement_enabled = false
	score = 0
	errors = 0
	
	# Using visibility layers to not affect layout
	step_1_label.visibility_layer = 0
	step_2_label.visibility_layer = 0
	step_1_label.visibility_layer = 1
	start_game_button.visibility_layer = 0
	try_again_button.visibility_layer = 0
	
	step = Steps.GREEN_MOVING_TO_SWITCH # start

func blink(node: CanvasItem) -> void:
	create_tween().tween_property(node, ":modulate", Color(1,1,1,0), 0.5).finished.connect(func()-> void:
		create_tween().tween_property(node, ":modulate", Color(1,1,1,1), 0.5)	
	)


func _on_rails_scored(_color: Train.TrainColor) -> void:
	score += 10


func _on_rails_errored() -> void:
	errors += 1


func _on_rails_end() -> void:
	start_game_button.visibility_layer = 1
	try_again_button.visibility_layer = 1
	BackgroundMovement.movement_enabled = true


func _on_close_button_pressed() -> void:
	get_tree().change_scene_to_file(Scenes.MAIN_MENU)


func _on_rails_switch_changed(_cell: Vector2i, is_active: bool) -> void:
	switch_is_active = is_active
