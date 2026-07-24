extends Control
var temp_options: Options



func _ready() -> void:
	self.hide()
	temp_options = GameManager.options

func _process(delta: float) -> void:
	pass

func _on_visibility_changed() -> void:
	temp_options = GameManager.options
	if temp_options == null or temp_options.framerate == null:
		return
		
	$"VSplitContainer/HSplitContainer/Right Column/Display/Fullscreen".button_pressed = temp_options.fullscreen
	$"VSplitContainer/HSplitContainer/Right Column/Display/VSync".button_pressed = temp_options.vsync
	if temp_options.vsync == true:
		$"VSplitContainer/HSplitContainer/Right Column/Display/FPS".editable = false
	$"VSplitContainer/HSplitContainer/Right Column/Display/FPSLabel/Value".text = str(temp_options.framerate, " fps")
	$"VSplitContainer/HSplitContainer/Right Column/Display/FPS".value = temp_options.framerate
	$"VSplitContainer/HSplitContainer/Right Column/Audio/MasterVolumeLabel/Value".text = str(temp_options.volume_master, "%")
	$"VSplitContainer/HSplitContainer/Right Column/Audio/MasterVolume".value = temp_options.volume_master
	GameManager.set_master_volume(temp_options.volume_master / 100.0)
	$"VSplitContainer/HSplitContainer/Right Column/Audio/MusicVolumeLabel/Value".text = str(temp_options.volume_music, "%")
	$"VSplitContainer/HSplitContainer/Right Column/Audio/MusicVolume".value = temp_options.volume_music 
	GameManager.set_music_volume(temp_options.volume_music / 100.0)
	$"VSplitContainer/HSplitContainer/Right Column/Audio/SFXVolumeLabel/Value".text = str(temp_options.volume_sfx, "%")
	$"VSplitContainer/HSplitContainer/Right Column/Audio/SFXVolume".value = temp_options.volume_sfx
	GameManager.set_sfx_volume(temp_options.volume_sfx / 100.0)

func _on_apply_pressed() -> void:
	GameManager.options = temp_options
	GameManager.save_options()

func _on_back_pressed() -> void:
	self.hide()
	temp_options = GameManager.options

func _on_reset_pressed() -> void:
	temp_options = Options.new()
	# TODO: Set visual options back to temp options, but don't touch GameManager in case they click back
	
func _on_resolution_item_selected(index: int) -> void:
	pass # Replace with function body.

func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		temp_options.fullscreen = true
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		temp_options.fullscreen = false

func _on_v_sync_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		temp_options.vsync = true
		temp_options.framerate = DisplayServer.screen_get_refresh_rate()
		$"VSplitContainer/HSplitContainer/Right Column/Display/FPSLabel/Value".text = str(temp_options.framerate, " fps")
		$"VSplitContainer/HSplitContainer/Right Column/Display/FPS".editable = false
		$"VSplitContainer/HSplitContainer/Right Column/Display/FPS".value = temp_options.framerate
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		temp_options.vsync = false
		temp_options.framerate = GameManager.options.framerate
		$"VSplitContainer/HSplitContainer/Right Column/Display/FPSLabel/Value".text = str(temp_options.framerate, " fps")
		$"VSplitContainer/HSplitContainer/Right Column/Display/FPS".editable = true
		$"VSplitContainer/HSplitContainer/Right Column/Display/FPS".value = temp_options.framerate
	
func _on_fps_value_changed(value: float) -> void:
	temp_options.framerate = $"VSplitContainer/HSplitContainer/Right Column/Display/FPS".value
	$"VSplitContainer/HSplitContainer/Right Column/Display/FPSLabel/Value".text = str(temp_options.framerate, " fps")
	Engine.max_fps = temp_options.framerate


func _on_master_volume_value_changed(value: float) -> void:
	temp_options.volume_master = $"VSplitContainer/HSplitContainer/Right Column/Audio/MasterVolume".value
	$"VSplitContainer/HSplitContainer/Right Column/Audio/MasterVolumeLabel/Value".text = str(temp_options.volume_master, "%")
	GameManager.set_master_volume(temp_options.volume_master / 100.0)

func _on_music_volume_value_changed(value: float) -> void:
	temp_options.volume_music = $"VSplitContainer/HSplitContainer/Right Column/Audio/MusicVolume".value
	$"VSplitContainer/HSplitContainer/Right Column/Audio/MusicVolumeLabel/Value".text = str(temp_options.volume_music, "%")
	GameManager.set_music_volume(temp_options.volume_music / 100.0)


func _on_sfx_volume_value_changed(value: float) -> void:
	temp_options.volume_sfx = $"VSplitContainer/HSplitContainer/Right Column/Audio/SFXVolume".value
	$"VSplitContainer/HSplitContainer/Right Column/Audio/SFXVolumeLabel/Value".text = str(temp_options.volume_sfx, "%")
	GameManager.set_sfx_volume(temp_options.volume_sfx / 100.0)
