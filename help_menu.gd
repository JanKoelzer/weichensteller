extends VBoxContainer

func _on_close_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
