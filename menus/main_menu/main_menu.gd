extends Control

@onready var quit_button: Button = $CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/QuitButton

func _ready() -> void:	
	if OS.get_name() == "Android":
		if not UISettings.file_exists():
			# First start. User has not accepted privacy yet.
			_change_scene_to_first_start.call_deferred()

	if OS.get_name() == "Web":
		# quit() does not work well in a browser
		quit_button.visible = false



func _change_scene_to_first_start() -> void:
	get_tree().change_scene_to_file(Scenes.FIRST_START)


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file(Scenes.DIFFICULTY_MENU)


func _on_highscore_button_pressed() -> void:
	get_tree().change_scene_to_file(Scenes.HIGHSCORE_MENU)


func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file(Scenes.CREDITS_MENU)


func _on_help_button_pressed() -> void:
	get_tree().change_scene_to_file(Scenes.HELP_MENU)
