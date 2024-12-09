extends VBoxContainer


func _ready() -> void:
	# react to future changes in settings
	GameSettings.changed.connect(func(_prop: String, _v: Variant) -> void:
			update_view()
	) 
	update_view()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().change_scene_to_file("res://main_menu.tscn")


func update_view() -> void:
	$GridContainer/SpeedLabel.text = str(round(GameSettings.speed*100))
	$GridContainer/NumConcurrentTrainsLabel.text = str(GameSettings.num_concurrent_trains)
	$GridContainer/NumStationsLabel.text = str(GameSettings.num_stations)
	$GridContainer/NumSwitchesLabel.text = str(GameSettings.num_extra_switches)
	$GridContainer/NumBrakesLabel.text = str(GameSettings.num_brakes)
	$GridContainer/MaxErrorsLabel.text = str(GameSettings.max_errors)
	
	var k: float = GameSettings.score_factor()
	$GridContainer/VBoxContainer/FactorLabel.text = str(int(k*100)) + " %"
	


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game_view.tscn")
	

func _on_speed_plus_button_pressed() -> void:
	GameSettings.speed += 0.05


func _on_speed_minus_button_pressed() -> void:
	GameSettings.speed -= 0.05


func _on_concurrent_plus_button_pressed() -> void:
	GameSettings.num_concurrent_trains += 1


func _on_concurrent_minus_button_pressed() -> void:
	GameSettings.num_concurrent_trains -= 1


func _on_stations_plus_button_pressed() -> void:
	GameSettings.num_stations += 1


func _on_stations_minus_button_pressed() -> void:
	GameSettings.num_stations -= 1


func _on_switches_plus_button_pressed() -> void:
	GameSettings.num_extra_switches += 1


func _on_switches_minus_button_pressed() -> void:
	GameSettings.num_extra_switches -= 1


func _on_brakes_plus_button_pressed() -> void:
	GameSettings.num_brakes += 1


func _on_brakes_minus_button_pressed() -> void:
	GameSettings.num_brakes -= 1


func _on_errors_plus_button_pressed() -> void:
	GameSettings.max_errors += 1


func _on_errors_minus_button_pressed() -> void:
	GameSettings.max_errors -= 1
