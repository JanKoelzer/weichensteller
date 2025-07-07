extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%ThirdPartyLabel.text ="\n".join(
			["Lizenzen verwendeter Software und Assets: ",
			Engine.get_license_text(),
			"Die Sounds stammen vom Freedesktop-Projekt."
			])


func _on_close_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
