extends VBoxContainer

@onready var privacy_container: ScrollContainer = %PrivacyContainer
@onready var introduction: VBoxContainer = $Introduction
@onready var tutorial_button: Button = %TutorialButton
@onready var close_button: Button = %CloseButton

func _on_close_button_pressed() -> void:
	UISettings.privacy_accpeted = true
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")


func _on_tutorial_button_pressed() -> void:
	UISettings.privacy_accpeted = true
	close_button.visible = true
	tutorial_button.visible = false
	privacy_container.visible = false
	introduction.visible = true
