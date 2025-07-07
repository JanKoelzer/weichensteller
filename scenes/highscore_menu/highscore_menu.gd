extends VBoxContainer


@onready
var highscore_labels := [
	%HighscoreTabContainer/Age0/HighscoreLabel,
	%HighscoreTabContainer/Age1/HighscoreLabel,
	%HighscoreTabContainer/Age2/HighscoreLabel,
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for group_idx: int in Highscore.AgeGroups.size():
		$HighscoreTabContainer.set_tab_title(group_idx, tr("AGE")+ " " + Highscore.AgeGroupNames[group_idx])
	Highscore.highscore_updated.connect(_on_highscore_updated)
	Highscore.receive_highscore()


func _on_highscore_updated(highscore: Dictionary) -> void:
	for group_idx: int in Highscore.AgeGroups.size():
		var group := Highscore.AgeGroupNames[group_idx] as String
		highscore_labels[group_idx].text = ""
		
		for i: int in highscore[group].size():
			var entry := highscore[group][i] as Dictionary
			highscore_labels[group_idx].text += "%s. %s, %s, %s\n" % [i+1, entry.name, roundi(entry.score), entry.date]


func _on_close_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
