extends VBoxContainer

@onready var speed_label: Label = $CenterContainer/GridContainer/SpeedLabel
@onready var num_concurrent_trains_label: Label = $CenterContainer/GridContainer/NumConcurrentTrainsLabel
@onready var num_switches_label: Label = $CenterContainer/GridContainer/NumSwitchesLabel
@onready var max_errors_label: Label = $CenterContainer/GridContainer/MaxErrorsLabel
@onready var station_buttons := [
	%StationButton0,
	%StationButton1,
	%StationButton2,
	%StationButton3,
	%StationButton4,
	%StationButton5,
]
@onready var factor_label: Label = $CenterContainer/GridContainer/VBoxContainer/FactorLabel
@onready var start_button: Button = %StartButton

func _ready() -> void:
	# Always start with valid settings.
	GameSettings.sanitize()
	
	# React to future changes in settings
	GameSettings.changed.connect(func(_prop: String, _v: Variant) -> void:
			update_view()
	)
	update_view()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().change_scene_to_file(Scenes.MAIN_MENU)


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(Scenes.MAIN_MENU)


func update_view() -> void:
	speed_label.text = str(roundi(GameSettings.speed*100))
	num_concurrent_trains_label.text = str(GameSettings.num_concurrent_trains)
	num_switches_label.text = str(GameSettings.num_extra_switches)
	max_errors_label.text = str(GameSettings.max_errors)
	
	update_stations()
	
	var k: float = GameSettings.score_factor()
	factor_label.text = str(roundi(k*100)) + " %"
	
	start_button.disabled = !GameSettings.is_valid()
	
func update_stations() -> void:	
	for i in range(station_buttons.size()):
		station_buttons[i].button_pressed = GameSettings.selected_stations.has(i)
		
	var anim_player := %NumStationsInvalidLabel/AnimationPlayer as AnimationPlayer
	
	if GameSettings.is_valid():
		anim_player.get_animation("changed_negative").loop_mode = Animation.LOOP_NONE
	else:
		anim_player.play("fade_in")
		anim_player.queue("changed_negative")
		anim_player.get_animation("changed_negative").loop_mode = Animation.LOOP_LINEAR


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file(Scenes.GAME_VIEW)


func _on_speed_plus_button_pressed() -> void:
	GameSettings.speed += 0.05


func _on_speed_minus_button_pressed() -> void:
	GameSettings.speed -= 0.05


func _on_concurrent_plus_button_pressed() -> void:
	GameSettings.num_concurrent_trains += 1


func _on_concurrent_minus_button_pressed() -> void:
	GameSettings.num_concurrent_trains -= 1


func _on_switches_plus_button_pressed() -> void:
	GameSettings.num_extra_switches += 1


func _on_switches_minus_button_pressed() -> void:
	GameSettings.num_extra_switches -= 1


func _on_errors_plus_button_pressed() -> void:
	GameSettings.max_errors += 1


func _on_errors_minus_button_pressed() -> void:
	GameSettings.max_errors -= 1


func _on_station_button_pressed() -> void:
	var selected_stations: Dictionary[int, bool] = { }
	for i in range(station_buttons.size()):
		if station_buttons[i].button_pressed:
			selected_stations[i] = true
	GameSettings.selected_stations = selected_stations
