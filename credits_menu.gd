extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%ThirdPartyLabel.text ="\n".join(
			["Lizenzen verwendeter Software und Assets: ",
			Engine.get_license_text(),
			"Die Sounds stammen vom Freedesktop-Projekt."
			])


func _on_close_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")