extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Popup.visible = false
	$Popup/Options.hide()
	self.process_mode = Node.PROCESS_MODE_ALWAYS


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_instance_valid(self):
		return
	if Input.is_action_just_pressed("ui_close_dialog"):
		$Popup.visible = not $Popup.visible
		get_tree().paused = $Popup.visible
		if $Popup/Options.visible:
			$Popup/Options._on_back_pressed()
			$Popup/Options.hide()
		$Popup/MenuButtons/Back.grab_focus()
		


func _on_back_pressed() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	$Popup.visible = false


func _on_options_pressed() -> void:
	$Popup/Options.show()
	$"Popup/Options/Margin/HSplitContainer/Left Column/Display".grab_focus()


func _on_reset_pressed() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	get_tree().reload_current_scene()
	$Popup.visible = false


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://ui/main_menu/main_menu.tscn")


func _on_options_focus_reset() -> void:
	$Popup/MenuButtons/Back.grab_focus()
