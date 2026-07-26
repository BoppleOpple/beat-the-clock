extends Control
var temp_options: Options

var resolutions: Array[Vector2i] = [
	Vector2i(1280,720),
	Vector2i(1600,900),
	Vector2i(1920,1080),
	Vector2i(2560,1440),
	Vector2i(3840,2160),
]

func _ready() -> void:
	self.hide()
	temp_options = GameManager.options
	for res in resolutions:
		$"Margin/HSplitContainer/Right Column/Display/Resolution".add_item("%d x %d" % [res.x, res.y])

func _process(delta: float) -> void:
	pass

func _on_visibility_changed() -> void:
	if self.visible == false:
		return
	temp_options = GameManager.options
	if temp_options == null or temp_options.framerate == null:
		return
	$"Margin/HSplitContainer/Left Column/Display".disabled = true
	$"Margin/HSplitContainer/Left Column/Audio".disabled = false
	$"Margin/HSplitContainer/Right Column/Display".show()
	$"Margin/HSplitContainer/Right Column/Audio".hide()
	$"Margin/HSplitContainer/Right Column/Display/Resolution".select(2)
	$"Margin/HSplitContainer/Right Column/Display/Fullscreen".button_pressed = temp_options.fullscreen
	$"Margin/HSplitContainer/Right Column/Display/VSync".button_pressed = temp_options.vsync
	if temp_options.vsync == true:
		$"Margin/HSplitContainer/Right Column/Display/FPS".editable = false
	$"Margin/HSplitContainer/Right Column/Display/FPSLabel/Value".text = str(temp_options.framerate, " fps")
	$"Margin/HSplitContainer/Right Column/Display/FPS".value = temp_options.framerate
	$"Margin/HSplitContainer/Right Column/Audio/MasterVolumeLabel/Value".text = str(temp_options.volume_master, "%")
	$"Margin/HSplitContainer/Right Column/Audio/MasterVolume".value = temp_options.volume_master
	GameManager.set_master_volume(temp_options.volume_master / 100.0)
	$"Margin/HSplitContainer/Right Column/Audio/MusicVolumeLabel/Value".text = str(temp_options.volume_music, "%")
	$"Margin/HSplitContainer/Right Column/Audio/MusicVolume".value = temp_options.volume_music 
	GameManager.set_music_volume(temp_options.volume_music / 100.0)
	$"Margin/HSplitContainer/Right Column/Audio/SFXVolumeLabel/Value".text = str(temp_options.volume_sfx, "%")
	$"Margin/HSplitContainer/Right Column/Audio/SFXVolume".value = temp_options.volume_sfx
	GameManager.set_sfx_volume(temp_options.volume_sfx / 100.0)

func _on_apply_pressed() -> void:
	GameManager.options = temp_options
	GameManager.save_options()
	GameManager.load_options()

func _on_back_pressed() -> void:
	GameManager.load_options()
	self.hide()
	temp_options = GameManager.options
	emit_signal("focus_reset")

func _on_reset_pressed() -> void:
	temp_options = Options.new()
	$"Margin/HSplitContainer/Right Column/Display/Resolution".select(2)
	$"Margin/HSplitContainer/Right Column/Display/Fullscreen".button_pressed = temp_options.fullscreen
	$"Margin/HSplitContainer/Right Column/Display/VSync".button_pressed = temp_options.vsync
	if temp_options.vsync == true:
		$"Margin/HSplitContainer/Right Column/Display/FPS".editable = false
	$"Margin/HSplitContainer/Right Column/Display/FPSLabel/Value".text = str(temp_options.framerate, " fps")
	$"Margin/HSplitContainer/Right Column/Display/FPS".value = temp_options.framerate
	$"Margin/HSplitContainer/Right Column/Audio/MasterVolumeLabel/Value".text = str(temp_options.volume_master, "%")
	$"Margin/HSplitContainer/Right Column/Audio/MasterVolume".value = temp_options.volume_master
	GameManager.set_master_volume(temp_options.volume_master / 100.0)
	$"Margin/HSplitContainer/Right Column/Audio/MusicVolumeLabel/Value".text = str(temp_options.volume_music, "%")
	$"Margin/HSplitContainer/Right Column/Audio/MusicVolume".value = temp_options.volume_music 
	GameManager.set_music_volume(temp_options.volume_music / 100.0)
	$"Margin/HSplitContainer/Right Column/Audio/SFXVolumeLabel/Value".text = str(temp_options.volume_sfx, "%")
	$"Margin/HSplitContainer/Right Column/Audio/SFXVolume".value = temp_options.volume_sfx
	GameManager.set_sfx_volume(temp_options.volume_sfx / 100.0)
	# TODO: Set visual options back to temp options, but don't touch GameManager in case they click back
	
func _on_display_pressed() -> void:
	$"Margin/HSplitContainer/Left Column/Display".disabled = true
	$"Margin/HSplitContainer/Left Column/Audio".disabled = false
	$"Margin/HSplitContainer/Right Column/Display".show()
	$"Margin/HSplitContainer/Right Column/Audio".hide()
	
func _on_audio_pressed() -> void:
	$"Margin/HSplitContainer/Left Column/Display".disabled = false
	$"Margin/HSplitContainer/Left Column/Audio".disabled = true
	$"Margin/HSplitContainer/Right Column/Display".hide()
	$"Margin/HSplitContainer/Right Column/Audio".show()

func _on_resolution_item_selected(index: int) -> void:
	var new_res = resolutions[$"Margin/HSplitContainer/Right Column/Display/Resolution".selected]
	temp_options.resolution_x = new_res.x
	temp_options.resolution_y = new_res.y

func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$"Margin/HSplitContainer/Right Column/Display/Resolution".disabled = true
		temp_options.fullscreen = true
	else:
		$"Margin/HSplitContainer/Right Column/Display/Resolution".disabled = false
		temp_options.fullscreen = false

func _on_v_sync_toggled(toggled_on: bool) -> void:
	if toggled_on:
		temp_options.vsync = true
		$"Margin/HSplitContainer/Right Column/Display/FPS".value = DisplayServer.screen_get_refresh_rate()
		$"Margin/HSplitContainer/Right Column/Display/FPSLabel/Value".text = str(int(DisplayServer.screen_get_refresh_rate()), " fps")
		$"Margin/HSplitContainer/Right Column/Display/FPS".editable = false
	else:
		temp_options.vsync = false
		$"Margin/HSplitContainer/Right Column/Display/FPS".value = temp_options.framerate
		$"Margin/HSplitContainer/Right Column/Display/FPSLabel/Value".text = str(temp_options.framerate, " fps")
		$"Margin/HSplitContainer/Right Column/Display/FPS".editable = true
	
func _on_fps_value_changed(value: float) -> void:
	if temp_options.vsync == false:
		temp_options.framerate = $"Margin/HSplitContainer/Right Column/Display/FPS".value
		$"Margin/HSplitContainer/Right Column/Display/FPSLabel/Value".text = str(temp_options.framerate, " fps")


func _on_master_volume_value_changed(value: float) -> void:
	temp_options.volume_master = $"Margin/HSplitContainer/Right Column/Audio/MasterVolume".value
	$"Margin/HSplitContainer/Right Column/Audio/MasterVolumeLabel/Value".text = str(temp_options.volume_master, "%")
	GameManager.set_master_volume(temp_options.volume_master / 100.0)

func _on_music_volume_value_changed(value: float) -> void:
	temp_options.volume_music = $"Margin/HSplitContainer/Right Column/Audio/MusicVolume".value
	$"Margin/HSplitContainer/Right Column/Audio/MusicVolumeLabel/Value".text = str(temp_options.volume_music, "%")
	GameManager.set_music_volume(temp_options.volume_music / 100.0)


func _on_sfx_volume_value_changed(value: float) -> void:
	temp_options.volume_sfx = $"Margin/HSplitContainer/Right Column/Audio/SFXVolume".value
	$"Margin/HSplitContainer/Right Column/Audio/SFXVolumeLabel/Value".text = str(temp_options.volume_sfx, "%")
	GameManager.set_sfx_volume(temp_options.volume_sfx / 100.0)
	
####################
# OUTGOING SIGNALS #
####################

signal focus_reset()
