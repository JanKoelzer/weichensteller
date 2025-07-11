class_name GameView
extends VBoxContainer

const COL_COUNT := 16

var time: int = 0
var error_count: int = 0
var score: float = 0.0
var pauses_left: int
var pause_time: int = 5

var errors_in_row: int = 0:
	get: return errors_in_row
	set(v):
		if v >= GameSettings.auto_brake_threshold and GameSettings.auto_brake_enabled:
			errors_in_row = 0
			auto_brake()
		else:
			errors_in_row = v


func _ready() -> void:
	# hide/show STOP buttons and checkbox
	if GameSettings.num_brakes > 0:
		pauses_left = GameSettings.num_brakes
		for i in range(pauses_left):
			var b: Button = Button.new()
			b.text = tr("STOP")
			b.pressed.connect(func() -> void: activate_brakes(b))
			%PauseButtons.add_child(b)
		# move CheckBox to the end of all its siblings
		%PauseButtons/AutoBrakeCheckBox.move_to_front()		
	else:
		%PauseButtons/AutoBrakeCheckBox.visible = false
	
	%PauseButtons/AutoBrakeCheckBox.button_pressed = GameSettings.auto_brake_enabled
	
	# start the game
	%Rails.init(COL_COUNT, GameSettings)
	start_after_countdown()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().change_scene_to_file("res://scenes/difficulty_settings/difficulty_settings.tscn")

	
func start_after_countdown() -> void:
	var label: Array[Label] = [%CountdownLabel0, %CountdownLabel1, %CountdownLabel2, %CountdownLabel3]
	for i in range(4):
		get_tree().create_timer(3-i).timeout.connect(func() -> void:
			label[i].find_child("AnimationPlayer").queue("fade_out")
			if i == 0:
				%Rails.start()
				$%CountdownEndAudioStreamPlayer.play()
			else:
				%CountdownAudioStreamPlayer.play()
				
		)


func activate_brakes(b: Button) -> void:
	b.disabled = true
	%Rails.pause_trains()	
	get_tree().create_timer(pause_time).timeout.connect(%Rails.resume_trains)
	

func _on_rails_scored() -> void:
	score += 10 * GameSettings.score_factor()
	errors_in_row = 0
	%ScoreLabel.text = str(roundi(score))
	%ScoreLabel/AnimationPlayer.play("changed")


func _on_rails_errored() -> void:
	self.error_count += 1
	self.errors_in_row += 1
	%ErrorsLabel.text = str(error_count)
	%ErrorsLabel/AnimationPlayer.play("changed")
	if error_count > GameSettings.max_errors:
		%ErrorsLabel/AnimationPlayer.get_animation("changed").loop_mode = Animation.LoopMode.LOOP_LINEAR
		sunset_game()
	else:
		%ErrorsLabel/AnimationPlayer.get_animation("changed").loop_mode = Animation.LoopMode.LOOP_NONE


func sunset_game() -> void:
	%Rails.generate_trains = false


func _on_timer_timeout() -> void:
	time += 1
	%TimeLabel.text = str(time)


func _on_rails_end() -> void:
	%Rails.generate_trains = false
	%TimeLabel/Timer.stop()
	%ErrorsLabel/AnimationPlayer.stop()
	%GameOverDisplay.visible = true
	%FinalScoreLabel.text = "Punkte: " + str(roundi(score))
	%FinalScoreLabel/AnimationPlayer.play("rainbow")
	%FinalScoreLabel/AnimationPlayer.speed_scale = 2.0
	
	%HighscoreControls.visible = true
	if OS.get_name() == "Web":
		# LineEdit/TextEdit do not work well in browsers.
		# Show a simple prompt as workauround
		var js: String = "prompt('%s')" % [tr("PROMPT_TEXT_JS")]
		var js_name := JavaScriptBridge.eval(js) as String
		%HighscoreControls.find_child("PlayerNameEdit").text = js_name


func _on_rails_train_started(sum_trains_started: int) -> void:
	%TrainCountLabel.text = str(sum_trains_started)
	%TrainCountLabel/AnimationPlayer.play("changed")


func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_difficulty_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/difficulty_settings/difficulty_settings.tscn")


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")


func _on_highscore_submit_button_pressed(age: String) -> void:
	var player_name := %HighscoreControls.find_child("PlayerNameEdit").text as String
	if player_name != null and player_name != "":
		if not Highscore.highscore_put.is_connected(_on_highscore_put):
			Highscore.highscore_put.connect(_on_highscore_put)
		Highscore.put_highscore(player_name, roundi(score), age)
		for button: Control in [%HighscoreControls/ChildSubmitButton, %HighscoreControls/PupilSubmitButton, %HighscoreControls/AdultSubmitButton]:
			button.disabled = true
		%HighscoreControls/SubmitStatusLabel.text = "…"
		%HighscoreControls/SubmitStatusLabel.visible = true

func _on_highscore_put(success: bool) -> void:
	if success:
		%HighscoreControls/SubmitStatusLabel.text = tr("OK")
	else:
		for button: Button in [%HighscoreControls/ChildSubmitButton, %HighscoreControls/PupilSubmitButton, %HighscoreControls/AdultSubmitButton]:
			button.disabled = false
		%HighscoreControls/SubmitStatusLabel.text = tr("PLEASE_RETRY")
	

func _on_auto_brake_check_box_toggled(toggled_on: bool) -> void:
	GameSettings.auto_brake_enabled = toggled_on


func auto_brake() -> void:
	var brakes := %PauseButtons.get_children()
	brakes = brakes.slice(0, brakes.size()-1) # skip checkbox
	for b in brakes:
		if not b.disabled:
			%PauseButtons/AutoBrakeCheckBox/AnimationPlayer.play("activated")
			get_tree().create_timer(pause_time).timeout.connect(func() -> void:
				%PauseButtons/AutoBrakeCheckBox/AnimationPlayer.pause()
			)
			activate_brakes(b as Button)
			break # activate only one brake
