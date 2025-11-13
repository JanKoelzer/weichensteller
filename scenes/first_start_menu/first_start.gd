extends VBoxContainer

func _on_close_button_pressed() -> void:
	UISettings.privacy_accpeted = true
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
