extends Control

@onready var quit_button: Button = $CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/QuitButton

func _ready() -> void:	
	if OS.get_name() == "Android":
		if not UISettings.privacy_accpeted:
			# First start. User has not accepted privacy yet.
			_change_scene_to_first_start.call_deferred()

	if OS.get_name() == "Web":
		# quit() does not work well in a browser
		quit_button.visible = false
	
	restore_rails()


func _change_scene_to_first_start() -> void:
	get_tree().change_scene_to_file(Scenes.FIRST_START)


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func store_rails() -> void:
	# Move $Rails to Scenes (i.e. a Global)
	# to get it back, when the MainMenu is opened again.
	# This keeps the state and does not start the train
	# movement all over again and again.
	var rails: Node2D = find_child("Rails", false, false)
	
	# disable $Rails
	rails.process_mode = Node.PROCESS_MODE_DISABLED
	rails.visible = false
	# Store $Rails by moving it to Scenes
	rails.reparent(Scenes)


func restore_rails() -> void:
	# If the main menu has been opened before, $Rails is
	# stored as a child of Scenes.
	# In this case, remove the default and replace it 
	# by the stored version.
	if Scenes.get_child_count() > 0:
		var stored_rails := Scenes.find_child("Rails", false, false) as Node2D
		if stored_rails != null:
			# move nodes inside the tree
			var default_rails := find_child("Rails")
			var idx := default_rails.get_index()
			remove_child(default_rails)
			stored_rails.reparent(self)
			move_child(stored_rails, idx)
			
			# enable new node, remove old node.
			stored_rails.process_mode = Node.PROCESS_MODE_INHERIT
			stored_rails.visible = true
			default_rails.queue_free()


func change_scene_to_file(uid: String) -> void:
	store_rails()
	get_tree().change_scene_to_file(uid)


func _on_start_button_pressed() -> void:
	change_scene_to_file(Scenes.DIFFICULTY_MENU)


func _on_highscore_button_pressed() -> void:
	change_scene_to_file(Scenes.HIGHSCORE_MENU)


func _on_credits_button_pressed() -> void:
	change_scene_to_file(Scenes.CREDITS_MENU)


func _on_help_button_pressed() -> void:
	change_scene_to_file(Scenes.HELP_MENU)
