class_name GameView
extends VBoxContainer

const COL_COUNT := 16

@onready var timer: Timer = $Timer
@onready var rails: TileMapLayer = %Rails
@onready var train_count_label: Label = %TrainCountLabel
@onready var score_label: Label = %ScoreLabel
@onready var errors_label: Label = %ErrorsLabel
@onready var time_label: Label = %TimeLabel
@onready var submit_status_label: Label = %HighscoreControls/SubmitStatusLabel
@onready var countdown_labels: Array[Label] = [
		%CountdownLabel0,
		%CountdownLabel1,
		%CountdownLabel2,
		%CountdownLabel3,
	]
@onready var score_factor := GameSettings.score_factor() # calculate only once

var time: int = 0
var error_count: int = 0
var score: float = 0.0
var score_str: String:
	get: return str(roundi(score))


func _ready() -> void:
	# start the game
	rails.init(COL_COUNT, GameSettings)
	count_down_and_start()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().change_scene_to_file("res://scenes/difficulty_settings/difficulty_settings.tscn")


func count_down_and_start() -> void:
	for i in countdown_labels.size():
		get_tree().create_timer(countdown_labels.size()-1-i).timeout.connect(func() -> void:
			countdown_labels[i].find_child("AnimationPlayer").queue(&"fade_in_out")
			if i == 0:
				rails.start()
				timer.start()
				$%CountdownEndAudioStreamPlayer.play()
			else:
				%CountdownAudioStreamPlayer.play()
				
		)


func _on_rails_scored() -> void:
	self.score += 10 * score_factor
	score_label.update(score_str)


func _on_rails_errored() -> void:
	self.error_count += 1
	
	if error_count > GameSettings.max_errors:
		errors_label.update(error_count, true)
		sunset_game()
	else:
		errors_label.update(error_count, false)


func sunset_game() -> void:
	rails.generate_trains = false


func _on_timer_timeout() -> void:
	time += 1
	time_label.text = str(time)


func _on_rails_end() -> void:
	rails.stop()
	timer.stop()
	%ErrorsLabel/AnimationPlayer.stop()
	%GameOverDisplay.visible = true
	%FinalScoreLabel.text = tr(&"SCORE") + " " + score_str
	%FinalScoreLabel/AnimationPlayer.play(&"rainbow")
	%FinalScoreLabel/AnimationPlayer.speed_scale = 2.0


func _on_rails_train_started(sum_trains_started: int) -> void:
	train_count_label.update(sum_trains_started)


func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_difficulty_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/difficulty_menu/difficulty_menu.tscn")


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")


func _on_highscore_submit_button_pressed(age: String) -> void:
	var player_name := %HighscoreControls.find_child("PlayerNameEdit").text as String
	if player_name != null and player_name != "":
		if not Highscore.highscore_put.is_connected(_on_highscore_put):
			Highscore.highscore_put.connect(_on_highscore_put)
		Highscore.put_highscore(player_name, roundi(score), age)
		
		for button: Control in get_tree().get_nodes_in_group("SubmitButton"):
			button.disabled = true
		submit_status_label.text = "…"
		submit_status_label.visible = true

func _on_highscore_put(success: bool) -> void:
	if success:
		submit_status_label.text = tr("SCORE_SAVE_OK")
		for button: Button in get_tree().get_nodes_in_group("SubmitButton"):
			button.visible = false
	else:
		for button: Button in get_tree().get_nodes_in_group("SubmitButton"):
			button.disabled = false
		submit_status_label.text = tr("PLEASE_RETRY")


func _on_player_name_edit_focus_entered() -> void:
	if OS.get_name() == "Web":
		# LineEdit/TextEdit do not work well in browsers.
		# Show a simple prompt as workauround
		var js: String = "prompt('%s')" % [tr("PROMPT_TEXT_JS")]
		var js_name := JavaScriptBridge.eval(js) as String
		%HighscoreControls.find_child("PlayerNameEdit").text = js_name
