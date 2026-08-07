extends Control


func _ready() -> void:
	$Popup.visible = false
	$Popup/Options.hide()
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	if not _is_server_or_singleplayer():
		# Only the host may restart the shared game state.
		$Popup/MenuButtons/Reset.disabled = true
		$Popup/MenuButtons/Reset.visible = false


func _process(delta: float) -> void:
	if not is_instance_valid(self):
		return
	if _is_game_over_showing():
		if $Popup.visible:
			_close()
		return
	if Input.is_action_just_pressed("ui_close_dialog"):
		if $Popup.visible:
			_close()
		else:
			$Popup.visible = true
			$Popup/MenuButtons/Back.grab_focus()


func _is_game_over_showing() -> bool:
	var main = get_tree().current_scene
	if main and main.has_node("GameOver"):
		var game_over = main.get_node("GameOver")
		if game_over.has_method("is_showing"):
			return game_over.is_showing()
	return false


func _close() -> void:
	Engine.time_scale = 1.0
	$Popup.visible = false
	if $Popup/Options.visible:
		$Popup/Options._on_back_pressed()
		$Popup/Options.hide()


func _on_back_pressed() -> void:
	_close()


func _on_options_pressed() -> void:
	$Popup/Options.show()
	$"Popup/Options/Margin/HSplitContainer/Left Column/Display".grab_focus()


func _on_reset_pressed() -> void:
	if not _is_server_or_singleplayer():
		return  # clients cannot restart the shared game
	_close()
	var main = get_tree().current_scene
	if main and main.has_method("_restart_game"):
		main._restart_game()


func _is_server_or_singleplayer() -> bool:
	return multiplayer.multiplayer_peer == null or multiplayer.is_server()


func _on_main_menu_pressed() -> void:
	Engine.time_scale = 1.0
	NetworkManager.disconnect_game()
	get_tree().change_scene_to_file("res://ui/main_menu/main_menu.tscn")


func _on_options_focus_reset() -> void:
	$Popup/MenuButtons/Back.grab_focus()
