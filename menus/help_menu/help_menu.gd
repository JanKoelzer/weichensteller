extends VBoxContainer

@onready var introduction: VBoxContainer = %Introduction

func _ready() -> void:
	introduction.start_tutorial()


func _on_close_button_pressed() -> void:
	get_tree().change_scene_to_file(Scenes.MAIN_MENU)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().change_scene_to_file(Scenes.MAIN_MENU)
