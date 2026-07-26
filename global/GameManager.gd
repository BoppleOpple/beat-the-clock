extends Node

const PLAYER_MAX_TIME: float = 30.5#300.5
var player: PlayerData
var player_ref: Player
var options: Options


const SAVE_GAME_PATH := "user://savegame.save"
const SAVE_OPTIONS_PATH := "user://options.save"
# -----------
# ABILITY VALUES
# 0 - Empty
# 1 - Dash
# 2 - Sword
# 3 - Grenade
# -----------

enum Ability {
	EMPTY = 0,
	DASH = 1,
	SWORD = 2,
	GRENADE = 3,
}

const ABILITY_COOLDOWN: Array[float] = [10.0, 2.0, 2.5, 3.0]

enum InputDevice { KEYBOARD_MOUSE, CONTROLLER }
var current_device := InputDevice.KEYBOARD_MOUSE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = PlayerData.new()
	options = Options.new()
	load_options()
	player.timer = 300.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	player.timer -= delta
	player.ability_1_cooldown -= delta
	player.ability_2_cooldown -= delta
	player.ability_3_cooldown -= delta
	player.ability_c_cooldown -= delta

func save_options() -> void:
	var options_dict := {
		"resolution_x": options.resolution_x,
		"resolution_y": options.resolution_y,
		"fullscreen": options.fullscreen,
		"vsync": options.vsync,
		"framerate": options.framerate,
		"volume_master": options.volume_master,
		"volume_music": options.volume_music,
		"volume_sfx": options.volume_sfx
		}
	var file := FileAccess.open(SAVE_OPTIONS_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(options_dict))
	file.close()
	print("Options Saved")
	
func load_options() -> void:
	if not FileAccess.file_exists(SAVE_OPTIONS_PATH):
		print("Options Created")
		return
	var file := FileAccess.open(SAVE_OPTIONS_PATH, FileAccess.READ)
	var text := file.get_as_text()
	file.close()
	var data = JSON.parse_string(text)
	if data == null:
		print("Options Loaded (empty)")
		return
	print("Options Loaded")
	options.resolution_x = data.get("resolution_x", 0)
	options.resolution_y = data.get("resolution_y", 0)
	options.fullscreen = data.get("fullscreen", 0)
	options.vsync = data.get("vsync", 0)
	options.framerate = data.get("framerate", 0)
	options.volume_master = data.get("volume_master", 0)
	options.volume_music = data.get("volume_music", 0)
	options.volume_sfx = data.get("volume_sfx", 0)
	_once_options_loaded()
	
func set_master_volume(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	
func set_music_volume(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	
func set_sfx_volume(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		current_device = InputDevice.KEYBOARD_MOUSE
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventJoypadMotion or event is InputEventJoypadButton:
		current_device = InputDevice.CONTROLLER
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		
func _once_options_loaded() -> void:
	DisplayServer.window_set_size(Vector2i(options.resolution_x, options.resolution_y))
	if options.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if options.vsync:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		options.framerate = DisplayServer.screen_get_refresh_rate()
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		Engine.max_fps = options.framerate
	set_master_volume(options.volume_master / 100.0)
	set_music_volume(options.volume_music / 100.0)
	set_sfx_volume(options.volume_sfx / 100.0)
	
