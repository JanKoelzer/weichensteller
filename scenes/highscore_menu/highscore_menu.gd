extends VBoxContainer


@onready
var highscore_labels := [
	%HighscoreTabContainer/Age0/HighscoreGrid/HighscoreLabel,
	%HighscoreTabContainer/Age1/HighscoreGrid/HighscoreLabel,
	%HighscoreTabContainer/Age2/HighscoreGrid/HighscoreLabel,
]
@onready
var highscore_grids := [
	%HighscoreTabContainer/Age0/HighscoreGrid,
	%HighscoreTabContainer/Age1/HighscoreGrid,
	%HighscoreTabContainer/Age2/HighscoreGrid,
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for group_idx: int in Highscore.AgeGroups.size():
		$HighscoreTabContainer.set_tab_title(group_idx, tr(&"AGE")+ " " + Highscore.AgeGroupNames[group_idx])
	Highscore.highscore_updated.connect(_on_highscore_updated)
	Highscore.highscore_update_failed.connect(_on_highscore_update_failed)
	Highscore.receive_highscore()

func _on_highscore_update_failed(_code:int) -> void:
	for l: Label in highscore_labels:
		l.text = tr(&"LOADING_FAILED")
	

func _on_highscore_updated(highscore: Dictionary) -> void:
	for l: Label in highscore_labels:
		l.visible = false
		
	for group_idx: int in Highscore.AgeGroups.size():
		var group := Highscore.AgeGroupNames[group_idx] as String
		create_sep_row(highscore_grids[group_idx])
		
		for i: int in highscore[group].size():			
			var entry := highscore[group][i] as Dictionary
			var values := [str(i+1) + ".", entry.name.substr(0, 30), str(roundi(entry.score)), entry.date] as Array[String]
			create_row(highscore_grids[group_idx], values)
			create_sep_row(highscore_grids[group_idx])


func create_row(grid_container: GridContainer, values: Array[String]) -> void:
	grid_container.add_child(VSeparator.new())
	for j in values.size():
		var l := create_label(values[j], j == 1)
		grid_container.add_child(l)
		grid_container.add_child(VSeparator.new())


func create_label(s: String, expand: bool = false) -> Label:
	var l := Label.new()
	l.text = s
	if expand:
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return l


func create_sep_row(grid_container: GridContainer) -> void:
	for j in range(grid_container.columns):
		grid_container.add_child(HSeparator.new())


func _on_close_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
