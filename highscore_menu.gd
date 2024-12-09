extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Highscore.highscore_updated.connect(_on_highscore_updated)
	Highscore.receive_highscore()


func _on_highscore_updated(highscore: Dictionary) -> void:
	%HighscoreLabel.text = ""
	for group: String in [Highscore.MIN, Highscore.MED, Highscore.MAX]:
		%HighscoreLabel.text += tr("AGE")+ " " + group + ":\n"
		for i: int in range(highscore[group].size()):
			var entry := highscore[group][i] as Dictionary
			%HighscoreLabel.text += "%s. %s, %s, %s\n" % [i+1, entry.name, entry.score, entry.date]
		%HighscoreLabel.text += "\n\n"


func _on_close_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().change_scene_to_file("res://main_menu.tscn")
